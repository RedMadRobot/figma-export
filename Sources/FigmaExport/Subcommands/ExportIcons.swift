import Foundation
import ArgumentParser
import FigmaAPI
import XcodeExport
import FigmaExportCore
import AndroidExport
import Logging

extension FigmaExportCommand {
    
    struct ExportIcons: ParsableCommand {
        
        static let configuration = CommandConfiguration(
            commandName: "icons",
            abstract: "Exports icons from Figma",
            discussion: "Exports icons from Figma to Xcode / Android Studio project")
        
        @Option(name: .shortAndLong, default: "figma-export.yaml",
                help: "An input YAML file with figma and platform properties.")
        var input: String
        
        @Argument(help: """
        [Optional] Name of the icons to export. For example \"ic/24/edit\" \
        to export single icon, \"ic/24/edit, ic/16/notification\" to export several icons and \
        \"ic/16/*\" to export all icons of size 16 pt
        """)
        var filter: String?
        
        func run() throws {
            let logger = Logger(label: "com.redmadrobot.figma-export")

            let reader = ParamsReader(inputPath: input)
            let params = try reader.read()

            guard let accessToken = ProcessInfo.processInfo.environment["FIGMA_PERSONAL_TOKEN"] else {
                throw FigmaExportError.accessTokenNotFound
            }
            let client = FigmaClient(accessToken: accessToken)
            
            if params.ios != nil {
                logger.info("Using FigmaExport to export icons to Xcode project.")
                try exportiOSIcons(client: client, params: params, logger: logger)
            }
            
            if params.android != nil {
                logger.info("Using FigmaExport to export icons to Android Studio project.")
                try exportAndroidIcons(client: client, params: params, logger: logger)
            }
        }
        
        private func exportiOSIcons(client: FigmaClient, params: Params, logger: Logger) throws {
            guard let ios = params.ios else {
                logger.info("Nothing to do. You haven’t specified ios parameter in the config file.")
                return
            }

            logger.info("Fetching icons info from Figma. Please wait...")
            let loader = ImagesLoader(figmaClient: client, params: params, platform: .ios)
            let images = try loader.loadIcons(filter: filter)

            logger.info("Processing icons...")
            let processor = ImagesProcessor(
                platform: .ios,
                nameValidateRegexp: params.common?.icons?.nameValidateRegexp,
                nameReplaceRegexp: params.common?.icons?.nameReplaceRegexp,
                nameStyle: params.ios?.icons.nameStyle
            )
            let icons = try processor.process(assets: images).get()

            let assetsURL = ios.xcassetsPath.appendingPathComponent(ios.icons.assetsFolder)
            let output = XcodeImagesOutput(
                assetsFolderURL: assetsURL,
                assetsInMainBundle: ios.xcassetsInMainBundle,
                preservesVectorRepresentation: ios.icons.preservesVectorRepresentation,
                uiKitImageExtensionURL: ios.icons.imageSwift,
                swiftUIImageExtensionURL: ios.icons.swiftUIImageSwift)
            
            let exporter = XcodeIconsExporter(output: output)
            let localAndRemoteFiles = try exporter.export(icons: icons, append: filter != nil)
            if filter == nil {
                try? FileManager.default.removeItem(atPath: assetsURL.path)
            }

            logger.info("Downloading remote files...")
            let localFiles = try fileDownloader.fetch(files: localAndRemoteFiles)

            logger.info("Writting files to Xcode project...")
            try fileWritter.write(files: localFiles)

            do {
                let xcodeProject = try XcodeProjectWritter(xcodeProjPath: ios.xcodeprojPath, target: ios.target)
                try localFiles.forEach { file in
                    if file.destination.file.pathExtension == "swift" {
                        try xcodeProject.addFileReferenceToXcodeProj(file.destination.url)
                    }
                }
                try xcodeProject.save()
            } catch {
                logger.error("Unable to add some file references to Xcode project")
            }
            
            logger.info("Done!")
        }
        
        private func exportAndroidIcons(client: FigmaClient, params: Params, logger: Logger) throws {
            guard let android = params.android, let androidIcons = android.icons else {
                logger.info("Nothing to do. You haven’t specified android.icons parameter in the config file.")
                return
            }
            
            // 1. Get Icons info
            logger.info("Fetching icons info from Figma. Please wait...")
            let loader = ImagesLoader(figmaClient: client, params: params, platform: .android)
            let images = try loader.loadIcons(filter: filter)

            // 2. Proccess images
            logger.info("Processing icons...")
            let processor = ImagesProcessor(
                platform: .android,
                nameValidateRegexp: params.common?.icons?.nameValidateRegexp,
                nameReplaceRegexp: params.common?.icons?.nameReplaceRegexp,
                nameStyle: .snakeCase
            )
            let icons = try processor.process(light: images, dark: nil).get()
            
            // Create empty temp directory
            let tempDirectoryURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        
            // 3. Download SVG files to user's temp directory
            logger.info("Downloading remote files...")
            let remoteFiles = icons.map { asset -> FileContents in
                let image = asset.light
                let fileURL = URL(string: "\(image.name).svg")!
                let dest = Destination(directory: tempDirectoryURL, file: fileURL)
                return FileContents(destination: dest, sourceURL: image.single.url)
            }
            var localFiles = try fileDownloader.fetch(files: remoteFiles)
            
            // 4. Move downloaded SVG files to new empty temp directory
            try fileWritter.write(files: localFiles)
            
            // 5. Convert all SVG to XML files
            logger.info("Converting SVGs to XMLs...")
            try svgFileConverter.convert(inputDirectoryPath: tempDirectoryURL.path)
            
            // Create output directory main/res/custom-directory/drawable/
            let outputDirectory = URL(fileURLWithPath: android.mainRes
                                        .appendingPathComponent(androidIcons.output)
                                        .appendingPathComponent("drawable", isDirectory: true).path)
            
            if filter == nil {
                // Clear output directory
                try? FileManager.default.removeItem(atPath: outputDirectory.path)
            }
            
            // 6. Move XML files to main/res/drawable/
            localFiles = localFiles.map { fileContents -> FileContents in
                
                let source = fileContents.destination.url
                    .deletingPathExtension()
                    .appendingPathExtension("xml")
                
                let fileURL = fileContents.destination.file
                    .deletingPathExtension()
                    .appendingPathExtension("xml")
                
                return FileContents(
                    destination: Destination(directory: outputDirectory, file: fileURL),
                    dataFile: source
                )
            }

            logger.info("Writting files to Android Studio project...")
            try fileWritter.write(files: localFiles)

            logger.info("Done!")
        }
    }
}
