import ArgumentParser
import Foundation
import FigmaAPI
import XcodeExport
import AndroidExport
import FigmaExportCore
import Logging

extension FigmaExportCommand {
    
    struct ExportTypography: ParsableCommand {
        
        static let configuration = CommandConfiguration(
            commandName: "typography",
            abstract: "Exports typography from Figma",
            discussion: "Exports font styles from Figma to Xcode")
        
        @Option(name: .shortAndLong, default: "figma-export.yaml", help: "An input YAML file with figma and platform properties.")
        var input: String
        
        func run() throws {
            let logger = Logger(label: "com.redmadrobot.figma-export")
            
            let reader = ParamsReader(inputPath: input)
            let params = try reader.read()

            guard let accessToken = ProcessInfo.processInfo.environment["FIGMA_PERSONAL_TOKEN"] else {
                throw FigmaExportError.accessTokenNotFound
            }
            let client = FigmaClient(accessToken: accessToken)

            logger.info("Using FigmaExport to export typography.")

            logger.info("Fetching text styles. Please wait...")
            let loader = TextStylesLoader(figmaClient: client, params: params.figma)
            let textStyles = try loader.load()

            if let ios = params.ios {//
                logger.info("Saving text styles...")
                try exportXcodeTextStyles(textStyles: textStyles, iosParams: ios, logger: logger)
                logger.info("Done!")
            }
        }
        
        private func exportXcodeTextStyles(textStyles: [TextStyle], iosParams: Params.iOS, logger: Logger) throws {
            let exporter = XcodeTypographyExporter()
            
            // UIFont+extension.swift
            var files = try exporter.exportFonts(
                textStyles: textStyles,
                fontExtensionDirectory: iosParams.typography.fontExtensionDirectory
            )
            
            if iosParams.typography.generateLabels {
                // Label.swift
                // LabelStyle.swift
                files.append(contentsOf: try exporter.exportLabels(
                    textStyles: textStyles,
                    labelsDirectory: iosParams.typography.labelsDirectory
                ))
            }
            try fileWritter.write(files: files)
            
            files.forEach {
                logger.notice("File \($0.destination.file) saved to directory \($0.destination.directory)")
            }
            logger.notice("Add referenece to these files in your Xcode project manually using drag&drop.")
        }
    }
}
