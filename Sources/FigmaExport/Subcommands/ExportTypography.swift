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
            let client = FigmaClient(accessToken: options.accessToken, timeout: options.params.figma.timeout)

            logger.info("Using FigmaExport \(FigmaExportCommand.version) to export typography.")

            logger.info("Fetching text styles. Please wait...")
            let loader = TextStylesLoader(client: client, params: options.params.figma)
            let textStyles = try loader.load()
            
            if let ios = options.params.ios,
               let typographyParams = ios.typography {
                
                logger.info("Processing typography...")
                let processor = TypographyProcessor(
                    platform: .ios,
                    nameValidateRegexp: options.params.common?.typography?.nameValidateRegexp,
                    nameReplaceRegexp: options.params.common?.typography?.nameReplaceRegexp,
                    nameStyle: typographyParams.nameStyle
                )
                let processedTextStyles = try processor.process(assets: textStyles).get()
                logger.info("Saving text styles...")
                try exportXcodeTextStyles(textStyles: processedTextStyles, iosParams: ios, logger: logger)
                logger.info("Done!")
            }

            if let android = options.params.android {
                logger.info("Processing typography...")
                let processor = TypographyProcessor(
                    platform: .android,
                    nameValidateRegexp: options.params.common?.typography?.nameValidateRegexp,
                    nameReplaceRegexp: options.params.common?.typography?.nameReplaceRegexp,
                    nameStyle: options.params.android?.typography?.nameStyle
                )
                let processedTextStyles = try processor.process(assets: textStyles).get()
                logger.info("Saving text styles...")
                try exportAndroidTextStyles(textStyles: processedTextStyles, androidParams: android, logger: logger)
                logger.info("Done!")
            }
        }
        
        private func exportXcodeTextStyles(textStyles: [TextStyle], iosParams: Params.iOS, logger: Logger) throws {
            let output = XcodeTypographyOutput(
                fontExtensionURL: iosParams.typography?.fontSwift,
                swiftUIFontExtensionURL: iosParams.typography?.swiftUIFontSwift,
                generateLabels: iosParams.typography?.generateLabels,
                labelsDirectory: iosParams.typography?.labelsDirectory,
                labelStyleExtensionsURL: iosParams.typography?.labelStyleSwift,
                addObjcAttribute: iosParams.addObjcAttribute
            )
            let exporter = XcodeTypographyExporter(output: output)
            let files = try exporter.export(textStyles: textStyles)
            
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

        private func exportAndroidTextStyles(textStyles: [TextStyle], androidParams: Params.Android, logger: Logger) throws {

            let exporter = AndroidTypographyExporter(outputDirectory: androidParams.mainRes)
            let files = try exporter.exportFonts(textStyles: textStyles)

            let fileURL = androidParams.mainRes.appendingPathComponent("values/typography.xml")

            try? FileManager.default.removeItem(atPath: fileURL.path)
            try fileWritter.write(files: files)
        }
    }
}
