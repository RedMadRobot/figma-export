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
        
        @OptionGroup
        var options: FigmaExportOptions
        
        func run() throws {
            let logger = Logger(label: "com.redmadrobot.figma-export")
            let (accessToken, params) = options.unpack
            let client = FigmaClient(accessToken: accessToken)

            logger.info("Using FigmaExport to export typography.")

            logger.info("Fetching text styles. Please wait...")
            let loader = TextStylesLoader(figmaClient: client, params: params.figma)
            let textStyles = try loader.load()

            if let ios = params.ios {
                logger.info("Saving text styles...")
                try exportXcodeTextStyles(textStyles: textStyles, iosParams: ios, logger: logger)
                logger.info("Done!")
            }
        }
        
        private func exportXcodeTextStyles(textStyles: [TextStyle], iosParams: Params.iOS, logger: Logger) throws {
            let exporter = XcodeTypographyExporter()
            
            var files: [FileContents] = []
            
            // UIKit UIFont extension
            if let fontExtensionURL = iosParams.typography.fontSwift {
                files.append(contentsOf: try exporter.exportFonts(
                    textStyles: textStyles,
                    fontExtensionURL: fontExtensionURL
                ))
            }
            
            // SwiftUI Font extension
            if let swiftUIFontExtensionURL = iosParams.typography.swiftUIFontSwift {
                files.append(contentsOf: try exporter.exportFonts(
                    textStyles: textStyles,
                    swiftUIFontExtensionURL: swiftUIFontExtensionURL
                ))
            }
            
            // UIKit Labels
            if iosParams.typography.generateLabels, let labelsDirectory = iosParams.typography.labelsDirectory  {
                // Label.swift
                // LabelStyle.swift
                files.append(contentsOf: try exporter.exportLabels(
                    textStyles: textStyles,
                    labelsDirectory: labelsDirectory
                ))
            }
            try fileWritter.write(files: files)
            
            do {
                let xcodeProject = try XcodeProjectWritter(xcodeProjPath: iosParams.xcodeprojPath, target: iosParams.target)
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
    }
}
