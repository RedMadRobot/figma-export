import ArgumentParser
import Foundation
import FigmaAPI
import XcodeExport
import AndroidExport
import FigmaExportCore

extension FigmaExportCommand {
    
    struct ExportTypography: ParsableCommand {
        
        static let configuration = CommandConfiguration(
            commandName: "typography",
            abstract: "Exports typography from Figma",
            discussion: "Exports font styles from Figma to Xcode")
        
        @OptionGroup
        var options: FigmaExportOptions
        
        func run() throws {
            let client = FigmaClient(accessToken: options.accessToken, timeout: options.params.figma.timeout)

            logger.info("Using FigmaExport \(FigmaExportCommand.version) to export typography.")

            logger.info("Fetching text styles. Please wait...")
            let loader = TextStylesLoader(
                client: client,
                params: options.params.figma,
                typoParams: options.params.common?.typography)
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
                try exportXcodeTextStyles(textStyles: processedTextStyles, iosParams: ios)
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
                try exportAndroidTextStyles(textStyles: processedTextStyles, androidParams: android)
                logger.info("Done!")
            }
        }
        
        private func createXcodeOutput(from iosParams: Params.iOS) -> XcodeTypographyOutput {
            let fontUrls = XcodeTypographyOutput.FontURLs(
                fontExtensionURL: iosParams.typography?.fontSwift,
                swiftUIFontExtensionURL: iosParams.typography?.swiftUIFontSwift
            )
            let labelUrls = XcodeTypographyOutput.LabelURLs(
                labelsDirectory: iosParams.typography?.labelsDirectory,
                labelStyleExtensionsURL: iosParams.typography?.labelStyleSwift
            )
            let urls = XcodeTypographyOutput.URLs(
                fonts: fontUrls,
                labels: labelUrls
            )
            return XcodeTypographyOutput(
                urls: urls,
                generateLabels: iosParams.typography?.generateLabels,
                addObjcAttribute: iosParams.addObjcAttribute,
                templatesPath: iosParams.templatesPath
            )
        }
        
        private func exportXcodeTextStyles(textStyles: [TextStyle], iosParams: Params.iOS) throws {
            let output = createXcodeOutput(from: iosParams)
            let exporter = XcodeTypographyExporter(output: output)
            let files = try exporter.export(textStyles: textStyles)
            
            try fileWriter.write(files: files)
            
            guard iosParams.xcassetsInSwiftPackage == false else { return }
            
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

        private func exportAndroidTextStyles(textStyles: [TextStyle], androidParams: Params.Android) throws {
            let output = AndroidOutput(
                xmlOutputDirectory: androidParams.mainRes,
                xmlResourcePackage: androidParams.resourcePackage,
                srcDirectory: androidParams.mainSrc,
                packageName: androidParams.typography?.composePackageName,
                templatesPath: androidParams.templatesPath
            )
            let exporter = AndroidTypographyExporter(output: output)
            let files = try exporter.exportFonts(textStyles: textStyles)

            let fileURL = androidParams.mainRes.appendingPathComponent("values/typography.xml")

            try? FileManager.default.removeItem(atPath: fileURL.path)
            try fileWriter.write(files: files)
        }
    }
}
