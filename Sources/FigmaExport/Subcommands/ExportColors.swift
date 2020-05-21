import ArgumentParser
import Foundation
import FigmaAPI
import XcodeExport
import AndroidExport
import FigmaExportCore
import Logging

extension FigmaExportCommand {
    
    struct ExportColors: ParsableCommand {
        
        static let configuration = CommandConfiguration(
            commandName: "colors",
            abstract: "Exports colors from Figma",
            discussion: "Exports light and dark color palette from Figma to Xcode / Android Studio project")
        
        @Option(name: .shortAndLong, default: "figma-export.yaml", help: "An input YAML file with figma and platform properties.")
        var input: String
        
        func run() throws {
            let logger = Logger(label: "com.redmadrobot.figma-export")
            
            let reader = ParamsReader(inputPath: input)
            let params = try reader.read()

            let client = FigmaClient(accessToken: params.figma.personalAccessToken)

            logger.info("Using FigmaExport to export colors.")

            logger.info("Fetching colors. Please wait...")
            let loader = ColorsLoader(figmaClient: client, params: params.figma)
            let colors = try loader.load()

            if let ios = params.ios {
                logger.info("Processing colors...")
                let processor = ColorsProcessor(
                    platform: .ios,
                    nameValidateRegexp: params.common?.colors.nameValidateRegexp,
                    nameStyle: params.ios?.colors.nameStyle
                )
                let colorPairs = try processor.process(light: colors.light, dark: colors.dark).get()

                logger.info("Exporting colors to Xcode project...")
                try exportXcodeColors(colorPairs: colorPairs, iosParams: ios)

                logger.info("Done!")
            }
            
            if let android = params.android {
                logger.info("Processing colors...")
                let processor = ColorsProcessor(
                    platform: .android,
                    nameValidateRegexp: params.common?.colors.nameValidateRegexp,
                    nameStyle: .snakeCase
                )
                let colorPairs = try processor.process(light: colors.light, dark: colors.dark).get()

                logger.info("Exporting colors to Android Studio project...")
                try exportAndroidColors(colorPairs: colorPairs, androidParams: android)

                logger.info("Done!")
            }
        }
        
        private func exportXcodeColors(colorPairs: [AssetPair<Color>], iosParams: Params.iOS) throws {
            let colorsURL = iosParams.xcassetsPath.appendingPathComponent(iosParams.colors.assetsFolder)
            
            let output = XcodeColorsOutput(
                assetsColorsURL: colorsURL,
                colorSwiftURL: iosParams.colors.colorSwift)

            let exporter = XcodeColorExporter(output: output)
            let files = exporter.export(colorPairs: colorPairs)
            try fileWritter.write(files: files)
        }

        private func exportAndroidColors(colorPairs: [AssetPair<Color>], androidParams: Params.Android) throws {
            let exporter = AndroidColorExporter(outputDirectory: androidParams.mainRes)
            let files = exporter.export(colorPairs: colorPairs)
            try fileWritter.write(files: files)
        }
    }
}
