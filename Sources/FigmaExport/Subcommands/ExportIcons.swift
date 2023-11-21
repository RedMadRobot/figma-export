import Foundation
import ArgumentParser
import FigmaAPI
import XcodeExport
import FigmaExportCore
import AndroidExport
#if os(Linux)
import FoundationXML
#endif

extension FigmaExportCommand {
    
    struct ExportIcons: ParsableCommand {
        
        static let configuration = CommandConfiguration(
            commandName: "icons",
            abstract: "Exports icons from Figma",
            discussion: "Exports icons from Figma to Xcode / Android Studio project")
        
        @OptionGroup
        var options: FigmaExportOptions
        
        @Argument(help: """
        [Optional] Name of the icons to export. For example \"ic/24/edit\" \
        to export single icon, \"ic/24/edit, ic/16/notification\" to export several icons and \
        \"ic/16/*\" to export all icons of size 16 pt
        """)
        var filter: String?
        
        func run() throws {
            let client = FigmaClient(accessToken: options.accessToken, timeout: options.params.figma.timeout)
            
            if options.params.ios != nil {
                logger.info("Using FigmaExport \(FigmaExportCommand.version) to export icons to Xcode project.")
                try exportiOSIcons(client: client, params: options.params)
            }
            
            if options.params.android != nil {
                logger.info("Using FigmaExport \(FigmaExportCommand.version) to export icons to Android Studio project.")
                try exportAndroidIcons(client: client, params: options.params)
            }
        }
        
        private func exportiOSIcons(client: Client, params: Params) throws {
            guard let ios = params.ios,
                  let iconsParams = ios.icons else {
                logger.info("Nothing to do. You haven’t specified ios.icons parameters in the config file.")
                return
            }

            logger.info("Fetching icons info from Figma. Please wait...")
            let loader = ImagesLoader(client: client, params: params, platform: .ios, logger: logger)
            let imagesTuple = try loader.loadIcons(filter: filter)

            logger.info("Processing icons...")
            let processor = ImagesProcessor(
                platform: .ios,
                nameValidateRegexp: params.common?.icons?.nameValidateRegexp,
                nameReplaceRegexp: params.common?.icons?.nameReplaceRegexp,
                nameStyle: iconsParams.nameStyle
            )

            let icons = processor.process(light: imagesTuple.light, dark: imagesTuple.dark)
            if let warning = icons.warning?.errorDescription {
                logger.warning("\(warning)")
            }

            let assetsURL = ios.xcassetsPath.appendingPathComponent(iconsParams.assetsFolder)

            let output = XcodeImagesOutput(
                assetsFolderURL: assetsURL,
                assetsInMainBundle: ios.xcassetsInMainBundle,
                assetsInSwiftPackage: ios.xcassetsInSwiftPackage,
                resourceBundleNames: ios.resourceBundleNames,
                addObjcAttribute: ios.addObjcAttribute,
                preservesVectorRepresentation: iconsParams.preservesVectorRepresentation,
                uiKitImageExtensionURL: iconsParams.imageSwift,
                swiftUIImageExtensionURL: iconsParams.swiftUIImageSwift,
                templatesPath: ios.templatesPath)
            
            let exporter = XcodeIconsExporter(output: output)
            let localAndRemoteFiles = try exporter.export(icons: icons.get(), append: filter != nil)
            if filter == nil {
                try? FileManager.default.removeItem(atPath: assetsURL.path)
            }

            logger.info("Downloading remote files...")
            let localFiles = try fileDownloader.fetch(files: localAndRemoteFiles)

            logger.info("Writting files to Xcode project...")
            try fileWriter.write(files: localFiles)

            guard params.ios?.xcassetsInSwiftPackage == false else {
                checkForUpdate(logger: logger)
                logger.info("Done!")
                return
            }
            
            do {
                let xcodeProject = try XcodeProjectWriter(xcodeProjPath: ios.xcodeprojPath, target: ios.target)
                try localFiles.forEach { file in
                    if file.destination.file.pathExtension == "swift" {
                        try xcodeProject.addFileReferenceToXcodeProj(file.destination.url)
                    }
                }
                try xcodeProject.save()
            } catch {
                logger.error("Unable to add some file references to Xcode project")
            }
            
            checkForUpdate(logger: logger)
            
            logger.info("Done!")
        }
        
        private func exportAndroidIcons(client: Client, params: Params) throws {
            guard let android = params.android, let androidIcons = android.icons else {
                logger.info("Nothing to do. You haven’t specified android.icons parameter in the config file.")
                return
            }
            
            // 1. Get Icons info
            logger.info("Fetching icons info from Figma. Please wait...")
            let loader = ImagesLoader(client: client, params: params, platform: .android, logger: logger)
            let imagesTuple = try loader.loadIcons(filter: filter)

            // 2. Proccess images
            logger.info("Processing icons...")
            let processor = ImagesProcessor(
                platform: .android,
                nameValidateRegexp: params.common?.icons?.nameValidateRegexp,
                nameReplaceRegexp: params.common?.icons?.nameReplaceRegexp,
                nameStyle: .snakeCase
            )

            let icons = processor.process(light: imagesTuple.light, dark: imagesTuple.dark)
            if let warning = icons.warning?.errorDescription {
                logger.warning("\(warning)")
            }
            
            // Create empty temp directory
            let tempDirectoryLightURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
            let tempDirectoryDarkURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        
            // 3. Download SVG files to user's temp directory
            logger.info("Downloading remote files...")
            let remoteFiles = try icons.get().flatMap { asset -> [FileContents] in
                let lightFiles = asset.light.images.map { image -> FileContents in
                    let fileURL = URL(string: "\(image.name).svg")!
                    let dest = Destination(directory: tempDirectoryLightURL, file: fileURL)
                    return FileContents(destination: dest, sourceURL: image.url, isRTL: image.isRTL)
                }
                let darkFiles = asset.dark?.images.map { image -> FileContents in
                    let fileURL = URL(string: "\(image.name).svg")!
                    let dest = Destination(directory: tempDirectoryDarkURL, file: fileURL)
                    return FileContents(destination: dest, sourceURL: image.url, dark: true, isRTL: image.isRTL)
                } ?? []
                return lightFiles + darkFiles
            }

            var localFiles = try fileDownloader.fetch(files: remoteFiles)
            
            // 4. Move downloaded SVG files to new empty temp directory
            try fileWriter.write(files: localFiles)
            
            // 5. Convert all SVG to XML files
            logger.info("Converting SVGs to XMLs...")
            try svgFileConverter.convert(inputDirectoryUrl: tempDirectoryLightURL)
            logger.info("Converting dark SVGs to XMLs...")
            try svgFileConverter.convert(inputDirectoryUrl: tempDirectoryDarkURL)
            
            // Create output directory main/res/custom-directory/drawable/
            let lightDirectory = URL(fileURLWithPath: android.mainRes
                .appendingPathComponent(androidIcons.output)
                .appendingPathComponent("drawable", isDirectory: true).path)

            let darkDirectory = URL(fileURLWithPath: android.mainRes
                .appendingPathComponent(androidIcons.output)
                .appendingPathComponent("drawable-night", isDirectory: true).path)
            
            if filter == nil {
                // Clear output directory
                try? FileManager.default.removeItem(atPath: lightDirectory.path)
                try? FileManager.default.removeItem(atPath: darkDirectory.path)
            }
            
            // 6. Move XML files to main/res/drawable/
            localFiles = localFiles.map { fileContents -> FileContents in
                let directory = fileContents.dark ? darkDirectory : lightDirectory
                
                let source = fileContents.destination.url
                    .deletingPathExtension()
                    .appendingPathExtension("xml")
                
                let fileURL = fileContents.destination.file
                    .deletingPathExtension()
                    .appendingPathExtension("xml")
                
                rewriteXMLFile(from: source, fileContents: fileContents)
                
                return FileContents(
                    destination: Destination(directory: directory, file: fileURL),
                    dataFile: source
                )
            }
            
            // 7. Create Compose extension if configured
            let output = AndroidOutput(
                xmlOutputDirectory: android.mainRes,
                xmlResourcePackage: android.resourcePackage,
                srcDirectory: android.mainSrc,
                packageName: android.icons?.composePackageName,
                templatesPath: android.templatesPath
            )
            let composeExporter = AndroidComposeIconExporter(output: output)
            let composeIconNames = Set(localFiles.filter{ fileContents in
                !fileContents.dark
            }.map { fileContents -> String in
                fileContents.destination.file.deletingPathExtension().lastPathComponent
            })
            let composeFile = try composeExporter.exportIcons(iconNames: Array(composeIconNames).sorted())
            composeFile.map { localFiles.append($0) }

            logger.info("Writing files to Android Studio project...")
            try fileWriter.write(files: localFiles)

            try? FileManager.default.removeItem(at: tempDirectoryLightURL)
            try? FileManager.default.removeItem(at: tempDirectoryDarkURL)

            checkForUpdate(logger: logger)
            
            logger.info("Done!")
        }
    }
}

private extension FigmaExportCommand.ExportIcons {
    private func rewriteXMLFile(from source: URL, fileContents: FileContents) {
        guard fileContents.isRTL,
              let attribute = XMLNode.attribute(withName: "android:autoMirrored", stringValue: "\(fileContents.isRTL)") as? XMLNode
        else { return }
        if let sourceXML = try? XMLDocument(contentsOf: source, options: .documentTidyXML) {
            try? sourceXML.nodes(forXPath: "//vector").forEach { node in
                guard let element = node as? XMLElement else { return }
                element.addAttribute(attribute)
            }

            do {
                FigmaExportCommand.logger.info("Adding autoMirrored property for xml file...")
                try FigmaExportCommand.fileWriter.write(xmlFile: sourceXML, directory: source)
            } catch {
                FigmaExportCommand.logger.info("Rewrite XMLFile - \(sourceXML) failed")
            }
        }
    }
}
