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
        
        @Option(name: .shortAndLong, help: "An input YAML file with figma and platform properties.")
        var input: String
        
        func run() throws {
            let logger = Logger(label: "com.redmadrobot.figma-export")
            
            let reader = ParamsReader(inputPath: input.isEmpty ? "figma-export.yaml" : input)
            let params = try reader.read()

            guard let accessToken = ProcessInfo.processInfo.environment["FIGMA_PERSONAL_TOKEN"] else {
                throw FigmaExportError.accessTokenNotFound
            }
            
            let client = FigmaClient(accessToken: accessToken)

            logger.info("Using FigmaExport to export typography.")

            logger.info("Fetching text styles. Please wait...")
            let loader = TextStylesLoader(figmaClient: client, params: params)
            let textStyles = try loader.load()

            if let ios = params.ios {//
                logger.info("Saving text styles...")
                try exportXcodeTextStyles(textStyles: textStyles, iosParams: ios, logger: logger)
                logger.info("Done!")
            }

            if let android = params.android {//
                logger.info("Processing colors...")
                let loader = ColorsLoader(figmaClient: client, params: params.figma)
                let colors = try loader.load()

                let processor = ColorsProcessor(
                    platform: .android,
                    nameValidateRegexp: params.common?.colors?.nameValidateRegexp,
                    nameReplaceRegexp: params.common?.colors?.nameReplaceRegexp,
                    ignoreBadNames: params.common?.colors?.ignoreBadNames,
                    nameStyle: .snakeCase
                )
                let colorPairs = try processor.process(light: colors.light, dark: colors.dark).get()

                logger.info("Saving text styles...")

                try exportAndroidTextStyles(
                    textStyles: textStyles,
                    colorPairs: colorPairs,
                    androidParams: android
                )
                logger.info("Done!")
            }
        }

        private func exportXcodeTextStyles(textStyles: [TextStyle], iosParams: Params.iOS, logger: Logger) throws {
            let exporter = XcodeTypographyExporter()
            
            var files: [FileContents] = []
            
            // Styles
            if let stylesDirectoryURL = iosParams.typography.stylesDirectory {
                files.append(
                    contentsOf: try exporter.exportStyles(
                        textStyles,
                        folderURL: stylesDirectoryURL,
                        fileName: iosParams.typography.stylesFileName,
                        version: iosParams.typography.typographyVersion,
                        format: .init(rawValue: iosParams.typography.format?.rawValue ?? "")
                    )
                )
            }
            
            // Components
            if iosParams.typography.generateComponents,
               let directory = iosParams.typography.componentsDirectory  {
                files.append(
                    contentsOf: try exporter.exportComponents(
                        textStyles: textStyles,
                        componentsDirectory: directory,
                        version: iosParams.typography.typographyVersion
                    )
                )
            }
            try fileWritter.write(files: files)
            
            do {
                let xcodeProject = try XcodeProjectWritter(
                    xcodeProjPath: iosParams.xcodeprojPath,
                    xcodeprojMainGroupName: iosParams.xcodeprojMainGroupName,
                    target: iosParams.target
                )
                try files.forEach { file in
                    if file.destination.file.pathExtension == "swift"  {
                        try xcodeProject.addFileReferenceToXcodeProj(file.destination.url)
                    }
                    if file.destination.file.pathExtension == "json" {
                        try xcodeProject.addFileReferenceToXcodeProj(
                            file.destination.url,
                            buildPhase: .resources
                        )
                    }
                }
                try xcodeProject.save()
            } catch (let error) {
                print(error)
            }
        }

        private func exportAndroidTextStyles(
            textStyles: [TextStyle],
            colorPairs: [AssetPair<Color>],
            androidParams: Params.Android)
        throws {
            let outputPatch = URL(fileURLWithPath: androidParams.mainRes
                .appendingPathComponent(androidParams.typography?.output ?? "").path)

            let exporter = AndroidTypographyExporter(
                outputDirectory: outputPatch,
                colorsMatchRegexp: androidParams.typography?.colorsMatchRegexp,
                strongMatchWithColors: androidParams.typography?.strongMatchWithColors,
                attributes:  androidParams.typography?.attributes
            )

            let files = exporter.makeTypographyFile(textStyles, colorPairs: colorPairs, dark: false)

            try fileWritter.write(files: [files])
        }
    }
}
