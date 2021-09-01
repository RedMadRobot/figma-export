import ArgumentParser
import Foundation
import FigmaAPI
import XcodeExport
import AndroidExport
import FigmaExportCore

extension FigmaExportCommand {
    
    struct ExportColors: ParsableCommand {
        
        static let configuration = CommandConfiguration(
            commandName: "colors",
            abstract: "Exports colors from Figma",
            discussion: "Exports light and dark color palette from Figma to Xcode / Android Studio project")

        @OptionGroup
        var options: FigmaExportOptions
        
        func run() throws {
            let client = FigmaClient(accessToken: options.accessToken, timeout: options.params.figma.timeout)

            logger.info("Using FigmaExport \(FigmaExportCommand.version) to export colors.")

            logger.info("Fetching colors. Please wait...")
            let loader = ColorsLoader(client: client, figmaParams: options.params.figma, colorParams: options.params.common?.colors)
            let colors = try loader.load()

            if let ios = options.params.ios {
                logger.info("Processing colors...")
                let processor = ColorsProcessor(
                    platform: .ios,
                    nameValidateRegexp: options.params.common?.colors?.nameValidateRegexp,
                    nameReplaceRegexp: options.params.common?.colors?.nameReplaceRegexp,
                    nameStyle: options.params.ios?.colors?.nameStyle
                )
                let colorPairs = processor.process(light: colors.light, dark: colors.dark)
                if let warning = colorPairs.warning?.errorDescription {
                    logger.warning("\(warning)")
                }

                logger.info("Exporting colors to Xcode project...")
                try exportXcodeColors(colorPairs: colorPairs.get(), iosParams: ios)

                checkForUpdate(logger: logger)
                
                logger.info("Done!")
            }
            
            if let android = options.params.android {
                logger.info("Processing colors...")
                let processor = ColorsProcessor(
                    platform: .android,
                    nameValidateRegexp: options.params.common?.colors?.nameValidateRegexp,
                    nameReplaceRegexp: options.params.common?.colors?.nameReplaceRegexp,
                    nameStyle: .snakeCase
                )
                let colorPairs = processor.process(light: colors.light, dark: colors.dark)
                if let warning = colorPairs.warning?.errorDescription {
                    logger.warning("\(warning)")
                }

                logger.info("Exporting colors to Android Studio project...")
                try exportAndroidColors(colorPairs: colorPairs.get(), androidParams: android)

                checkForUpdate(logger: logger)
                
                logger.info("Done!")
            }
        }
        
        private func exportXcodeColors(colorPairs: [AssetPair<Color>], iosParams: Params.iOS) throws {
            guard let colorParams = iosParams.colors else {
                logger.error("Nothing to do. Add ios.colors parameters to the config file.")
                return
            }
            
            var colorsURL: URL?
            if colorParams.useColorAssets {
                if let folder = colorParams.assetsFolder {
                    colorsURL = iosParams.xcassetsPath.appendingPathComponent(folder)
                } else {
                    throw FigmaExportError.colorsAssetsFolderNotSpecified
                }
            }
            
            let output = XcodeColorsOutput(
                assetsColorsURL: colorsURL,
                assetsInMainBundle: iosParams.xcassetsInMainBundle,
                assetsInSwiftPackage: iosParams.xcassetsInSwiftPackage,
                addObjcAttribute: iosParams.addObjcAttribute,
                colorSwiftURL: colorParams.colorSwift,
                swiftuiColorSwiftURL: colorParams.swiftuiColorSwift,
                groupUsingNamespace: colorParams.groupUsingNamespace)

            let exporter = XcodeColorExporter(output: output)
            let files = exporter.export(colorPairs: colorPairs)
            
            if colorParams.useColorAssets, let url = colorsURL {
                try? FileManager.default.removeItem(atPath: url.path)
            }
            
            try fileWriter.write(files: files)
            
            do {
                let xcodeProject = try XcodeProjectWriter(xcodeProjPath: iosParams.xcodeprojPath, target: iosParams.target)
                try files.forEach { file in
                    if file.destination.file.pathExtension == "swift" {
                        try xcodeProject.addFileReferenceToXcodeProj(file.destination.url)
                    }
                }
                try xcodeProject.save()
            } catch {
                logger.error("Unable to add some file references to Xcode project")
            }
        }

        private func exportAndroidColors(colorPairs: [AssetPair<Color>], androidParams: Params.Android) throws {
            let exporter = AndroidColorExporter(outputDirectory: androidParams.mainRes)
            let files = exporter.export(colorPairs: colorPairs)
            
            let lightColorsFileURL = androidParams.mainRes.appendingPathComponent("values/colors.xml")
            let darkColorsFileURL = androidParams.mainRes.appendingPathComponent("values-night/colors.xml")
            
            try? FileManager.default.removeItem(atPath: lightColorsFileURL.path)
            try? FileManager.default.removeItem(atPath: darkColorsFileURL.path)
            
            try fileWriter.write(files: files)
        }
    }
}
