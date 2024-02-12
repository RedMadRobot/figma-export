import ArgumentParser
import Foundation
import FigmaAPI
import XcodeExport
import AndroidExport
import FigmaExportCore
import Logging

extension FigmaExportCommand {

    struct ExportDimensions: ParsableCommand {

        static let configuration = CommandConfiguration(
            commandName: "dimensions",
            abstract: "Exports dimensions from Figma",
            discussion: "Exports dimensions of the component from Figma to Xcode / Android Studio project")

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

            logger.info("Using FigmaExport to export dimensions.")

            logger.info("Fetching dimensons. Please wait...")
            let loader = DimensionsLoader(figmaClient: client, params: params)
            if (params.common?.dimensions?.componentNames ?? []).isEmpty {
                logger.info("Nothing to export. Please, fill the array common.dimensions.componentNames in figma-export.yaml")
                return
            }
            let components = try loader.load()

            if components.isEmpty {
                logger.info("Nothing to export. Please, check your figma-file and the array common.dimensions.componentNames in figma-export.yaml")
                return
            }

            if let ios = params.ios,
               let dimensions = ios.dimensions {

                logger.info("Exporting dimensions to Xcode project...")
                try exportXcodeDimensions(
                    components: components,
                    iosParams: ios,
                    dimensions: dimensions,
                    logger: logger
                )
                logger.info("Done!")
            }
            if let android = params.android {
                logger.info("Exporting colors to Android Studio project...")
                try exportAndroidDimensions(components: components, androidParams: android)

                logger.info("Done!")
            }
        }

        private func exportXcodeDimensions(
            components: [UIComponent],
            iosParams: Params.iOS,
            dimensions: Params.iOS.Dimensions,
            logger: Logger
        ) throws {

            let exporter = XcodeDimensionsExporter()
            let file = try exporter.export(
                components,
                folderURL: dimensions.dimensionsDirectory,
                fileName: dimensions.dimensionsFileName
            )

            try fileWritter.write(files: [file])

            do {
                let xcodeProject = try XcodeProjectWritter(
                    xcodeProjPath: iosParams.xcodeprojPath,
                    xcodeprojMainGroupName: iosParams.xcodeprojMainGroupName,
                    target: iosParams.target
                )
                if file.destination.file.pathExtension == "swift" {
                    try xcodeProject.addFileReferenceToXcodeProj(file.destination.url)
                }
                if file.destination.file.pathExtension == "json" {
                    try xcodeProject.addFileReferenceToXcodeProj(file.destination.url, buildPhase: .resources)
                }
                try xcodeProject.save()
            } catch (let error) {
                print(error)
            }
        }

        private func exportAndroidDimensions(
            components: [UIComponent],
            androidParams: Params.Android
        ) throws {
            let outputPatch = URL(fileURLWithPath: androidParams.mainRes
                .appendingPathComponent(androidParams.dimensions?.output ?? "").path)

            let exporter = AndroidDimensionsExporter(outputDirectory: outputPatch)
            let file = exporter.makeDimensionsFile(components)

            try fileWritter.write(files: [file])
        }
    }
}
