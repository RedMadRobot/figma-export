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
            let versionManager = VersionManager(versionFilePath: "figma-versions.json")
            let lastAvailableDate = shouldUpdateFigmaVersion(for: .typography, options: options, logger: logger, versionManager: versionManager)
            guard let lastAvailableDate else { return }
            
            let client = FigmaClient(accessToken: options.accessToken, timeout: options.params.figma.timeout)

            logger.info("Fetching text styles. Please wait...")
            let loader = TextStylesLoader(client: client, params: options.params.figma)
            let textStyles = try loader.load()
            
            if let _ = options.params.ios {
                logger.info("Using FigmaExport \(FigmaExportCommand.version) to export typography to Xcode project.")
                try exportiOSIcons(params: options.params, textStyles: textStyles)
            }
            
            if let _ = options.params.android {
                logger.info("Using FigmaExport \(FigmaExportCommand.version) to export typography to Android Studio project.")
                try exportAndroidIcons(params: options.params, textStyles: textStyles)
            }
            
            versionManager.setVersionDate(lastAvailableDate, for: .typography)
        }
        
        private func exportiOSIcons(params: Params, textStyles: [TextStyle]) throws {
            guard let ios = options.params.ios, let typographyParams = ios.typography else {
                throw FigmaExportError.custom(errorString: "Nothing to do. Add ios.typography parameters to the config file.")
            }
            
            logger.info("Processing typography...")
            let iOSProcessor = TypographyProcessor(
                platform: .ios,
                nameValidateRegexp: params.common?.typography?.nameValidateRegexp,
                nameReplaceRegexp: params.common?.typography?.nameReplaceRegexp,
                nameStyle: typographyParams.nameStyle
            )
            let iOSProcessedTextStyles = try iOSProcessor.process(assets: textStyles).get()
            logger.info("Saving text styles...")
            try exportXcodeTextStyles(textStyles: iOSProcessedTextStyles, iosParams: ios)
            logger.info("Done!")
        }
        
        private func exportAndroidIcons(params: Params, textStyles: [TextStyle]) throws {
            guard let android = options.params.android else {
                throw FigmaExportError.custom(errorString: "Nothing to do. Add android.typography parameters to the config file.")
            }
            
            logger.info("Processing typography...")
            let androidProcessor = TypographyProcessor(
                platform: .android,
                nameValidateRegexp: params.common?.typography?.nameValidateRegexp,
                nameReplaceRegexp: params.common?.typography?.nameReplaceRegexp,
                nameStyle: params.android?.typography?.nameStyle
            )
            let androidProcessedTextStyles = try androidProcessor.process(assets: textStyles).get()
            logger.info("Saving text styles...")
            try exportAndroidTextStyles(textStyles: androidProcessedTextStyles, androidParams: android)
            logger.info("Done!")
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
