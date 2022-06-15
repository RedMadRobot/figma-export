import Foundation
import ArgumentParser
import FigmaAPI
import XcodeExport
import FigmaExportCore
import AndroidExport

extension FigmaExportCommand {
    
    struct ExportSpacings: ParsableCommand {
        
        static let configuration = CommandConfiguration(
            commandName: "spacings",
            abstract: "Exports spacings from Figma",
            discussion: "Exports spacings from Figma")
        
        @OptionGroup
        var options: FigmaExportOptions
        
        func run() throws {
            let client = FigmaClient(accessToken: options.accessToken, timeout: options.params.figma.timeout)

            logger.info("Using FigmaExport \(FigmaExportCommand.version) to export spacings.")

            if let ios = options.params.ios {
                
                logger.info("Fetching spacings. Please wait...")
                let loader = SpacingsLoader(client: client, params: options.params, platform: .ios)
                let spacings = try loader.load()
                
                logger.info("Processing spacings...")
                let processor = SpacingsProcessor(
                    platform: .ios,
                    nameValidateRegexp: options.params.common?.spacings?.nameValidateRegexp,
                    nameReplaceRegexp: options.params.common?.spacings?.nameReplaceRegexp,
                    nameStyle: options.params.ios?.spacings?.nameStyle
                )
                let processedSpacings = try processor.process(assets: spacings).get()
                logger.info("Saving spacings...")
                try exportXcodeSpacings(spacings: processedSpacings, iosParams: ios)
                logger.info("Done!")
            }

            if let android = options.params.android {
                logger.info("Fetching spacings. Please wait...")
                let loader = SpacingsLoader(client: client, params: options.params, platform: .android)
                let spacings = try loader.load()
                
                logger.info("Processing spacings...")
                let processor = SpacingsProcessor(
                    platform: .android,
                    nameValidateRegexp: options.params.common?.spacings?.nameValidateRegexp,
                    nameReplaceRegexp: options.params.common?.spacings?.nameReplaceRegexp,
                    nameStyle: options.params.android?.spacings?.nameStyle
                )
                let processedSpacings = try processor.process(assets: spacings).get()
                logger.info("Saving spacings...")
                try exportAndroidSpacings(spacings: processedSpacings, androidParams: android)
                logger.info("Done!")
            }
        }
        
        private func createXcodeOutput(from iosParams: Params.iOS) -> XcodeSpacingsOutput {
            return XcodeSpacingsOutput(
                spacingsUrl: iosParams.spacings?.spacingsSwift,
                addObjcAttribute: iosParams.addObjcAttribute,
                templatesPath: iosParams.templatesPath
            )
        }
        
        private func exportXcodeSpacings(spacings: [Spacing], iosParams: Params.iOS) throws {
            let output = createXcodeOutput(from: iosParams)
            let exporter = XcodeSpacingsExporter(output: output)
            let files = try exporter.export(spacings: spacings)
            
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

        private func exportAndroidSpacings(spacings: [Spacing], androidParams: Params.Android) throws {
            let output = AndroidOutput(
                xmlOutputDirectory: androidParams.mainRes,
                xmlResourcePackage: androidParams.resourcePackage,
                srcDirectory: androidParams.mainSrc,
                packageName: androidParams.typography?.composePackageName,
                templatesPath: androidParams.templatesPath
            )
            let exporter = AndroidSpacingsExporter(output: output)
            let files = try exporter.exportSpacings(spacings: spacings)

            let fileURL = androidParams.mainRes.appendingPathComponent("values/dimens.xml")

            try? FileManager.default.removeItem(atPath: fileURL.path)
            try fileWriter.write(files: files)
        }
    }
}
