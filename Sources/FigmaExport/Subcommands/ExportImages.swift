import Foundation
import ArgumentParser
import FigmaAPI
import XcodeExport
import FigmaExportCore
import AndroidExport
import Logging

extension FigmaExportCommand {

    struct ExportImages: ParsableCommand {

        static let configuration = CommandConfiguration(
            commandName: "images",
            abstract: "Exports images from Figma",
            discussion: "Exports images from Figma to Xcode / Android Studio project")

        @Option(name: .shortAndLong, default: "figma-export.yaml", help: "An input YAML file with figma and platform properties.")
        var input: String
        
        @Argument(help: "[Optional] Name of the images to export. For example \"img/login\" to export single image, \"img/onboarding/1, img/onboarding/2\" to export several images and \"img/onboarding/*\" to export all images from onboarding group")
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
                logger.info("Using FigmaExport to export images to Xcode project.")
                try exportiOSImages(client: client, params: params, logger: logger)
            }

            if params.android != nil {
                logger.info("Using FigmaExport to export images to Android Studio project.")
                try exportAndroidImages(client: client, params: params, logger: logger)
            }
        }

        private func exportiOSImages(client: FigmaClient, params: Params, logger: Logger) throws {
            guard let ios = params.ios else { return }

            logger.info("Fetching images info from Figma. Please wait...")
            let loader = ImagesLoader(figmaClient: client, params: params.figma, platform: .ios)
            let imagesTuple = try loader.loadImages(filter: filter)

            logger.info("Processing images...")
            let processor = ImagesProcessor(
                platform: .ios,
                nameValidateRegexp: params.common?.images.nameValidateRegexp,
                nameStyle: params.ios?.images.nameStyle
            )
            let images = try processor.process(light: imagesTuple.light, dark: imagesTuple.dark).get()

            let assetsURL = ios.xcassetsPath.appendingPathComponent(ios.images.assetsFolder)
            
            let output = XcodeImagesOutput(
                assetsFolderURL: assetsURL,
                assetsInMainBundle: ios.xcassetsInMainBundle,
                uiKitImageExtensionURL: ios.images.imageSwift,
                swiftUIImageExtensionURL: ios.images.swiftUIImageSwift)
            
            let exporter = XcodeImagesExporter(output: output)
            let localAndRemoteFiles = try exporter.export(assets: images, append: filter != nil)
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
        
        private func exportAndroidImages(client: FigmaClient, params: Params, logger: Logger) throws {
            guard let android = params.android else { return }

            // 1. Get Images info
            logger.info("Fetching images info from Figma. Please wait...")
            let loader = ImagesLoader(figmaClient: client, params: params.figma, platform: .android)
            let imagesTuple = try loader.loadImages(filter: filter)

            // 2. Proccess images
            logger.info("Processing images...")
            let processor = ImagesProcessor(
                platform: .android,
                nameValidateRegexp: params.common?.images.nameValidateRegexp,
                nameStyle: .snakeCase
            )
            let images = try processor.process(light: imagesTuple.light, dark: imagesTuple.dark).get()
            
            // Create empty temp directory
            let tempDirectoryLightURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
            let tempDirectoryDarkURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)

            // 3. Download SVG files to user's temp directory
            logger.info("Downloading remote files...")
            let remoteFiles = images.flatMap { asset -> [FileContents] in
                let image = asset.light
                let fileURL = URL(string: "\(image.name).svg")!
                let dest = Destination(directory: tempDirectoryLightURL, file: fileURL)
                var result = [FileContents(destination: dest, sourceURL: image.single.url)]

                if let dark = asset.dark {
                    let fileURL = URL(string: "\(dark.name).svg")!
                    let dest = Destination(directory: tempDirectoryDarkURL, file: fileURL)
                    var file = FileContents(destination: dest, sourceURL: dark.single.url)
                    file.dark = true
                    result.append(file)
                }
                return result
            }
            var localFiles = try fileDownloader.fetch(files: remoteFiles)
            
            // 4. Move downloaded SVG files to new empty temp directory
            try fileWritter.write(files: localFiles)
            
            // 5. Convert all SVG to XML files
            logger.info("Converting SVGs to XMLs...")
            try fileConverter.convert(inputDirectoryPath: tempDirectoryLightURL.path)
            if imagesTuple.dark != nil {
                logger.info("Converting dark SVGs to XMLs...")
                try fileConverter.convert(inputDirectoryPath: tempDirectoryDarkURL.path)
            }

            logger.info("Writting files to Android Studio project...")
            // Create output directory main/res/drawable/
            let lightDirectory = URL(fileURLWithPath: android.mainRes.path)
                .appendingPathComponent("drawable", isDirectory: true)
            
            let darkDirectory = URL(fileURLWithPath: android.mainRes.path)
                .appendingPathComponent("drawable-night", isDirectory: true)
            
            // 6. Move XML files to main/res/drawable/
            localFiles = localFiles.map { fileContents -> FileContents in
                
                let source = fileContents.destination.url
                    .deletingPathExtension()
                    .appendingPathExtension("xml")
                
                let fileURL = fileContents.destination.file
                    .deletingPathExtension()
                    .appendingPathExtension("xml")
                
                let directory = fileContents.dark ? darkDirectory : lightDirectory
                
                return FileContents(
                    destination: Destination(directory: directory, file: fileURL),
                    dataFile: source
                )
            }
            try fileWritter.write(files: localFiles)
            logger.info("Done!")

            try FileManager.default.removeItem(at: tempDirectoryLightURL)
            try FileManager.default.removeItem(at: tempDirectoryDarkURL)
        }
    }
}
