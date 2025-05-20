import Foundation
import FigmaExportCore

public final class FlutterIconsExporter: FlutterExporterBase {
    enum Error: Swift.Error, LocalizedError {
        case unspecifiedVariation(String, String)

        var errorDescription: String? {
            switch self {
            case let .unspecifiedVariation(variation, icon):
                "Variation \"\(variation)\" is not specified for the icon \"\(icon)\". Skipping \"\(icon)\"."
            }
        }
    }

    let output: FlutterIconsOutput

    public init(output: FlutterIconsOutput) {
        self.output = output
    }

    public func export(icons: [AssetPair<ImagePack>]) throws -> (files: [FileContents], warnings: ErrorGroup) {
        var usedVariations: Set<ImageVariation> = [.light]
        for icon in icons {
            if usedVariations.count == ImageVariation.allCases.count {
                break
            }
            if icon.dark != nil { usedVariations.insert(.dark) }
            if icon.lightHC != nil { usedVariations.insert(.lightHighContrast) }
            if icon.darkHC != nil { usedVariations.insert(.darkHighContrast) }
        }
        let variations = Array(usedVariations).sorted()
        var iconsData: [IconData] = []
        var warnings: [Swift.Error] = []
        let iconFiles = icons.flatMap { icon -> [FileContents] in
            do {
                try validateName(icon.light.name)
            } catch {
                warnings.append(error)
                return []
            }
            var variationsData: [String: URL] = [:]
            var files: [FileContents] = []
            for variation in variations {
                switch variation {
                case .light:
                    guard let file = makeAndRegisterFileContents(
                        variationsData: &variationsData,
                        imagePack: icon.light,
                        variation: .light
                    ) else {
                        warnings.append(Error.unspecifiedVariation(variation.rawValue, icon.light.name))
                        return []
                    }
                    files.append(file)
                case .dark:
                    if let file = makeAndRegisterFileContents(
                        variationsData: &variationsData,
                        imagePack: icon.dark,
                        variation: .dark
                    ) {
                        files.append(file)
                    }
                case .lightHighContrast:
                    if let file = makeAndRegisterFileContents(
                        variationsData: &variationsData,
                        imagePack: icon.lightHC,
                        variation: .lightHighContrast
                    ) {
                        files.append(file)
                    }
                case .darkHighContrast:
                    if let file = makeAndRegisterFileContents(
                        variationsData: &variationsData,
                        imagePack: icon.darkHC,
                        variation: .darkHighContrast
                    ) {
                        files.append(file)
                    }
                }
            }
            iconsData.append(IconData(name: icon.light.name, variations: variationsData))
            return files
        }

        let context: [String: Any] = [
            "iconsClassName": output.iconsClassName,
            "baseAssetClass": output.baseAssetClass,
            "baseAssetClassFilePath": output.baseAssetClassFilePath,
            "variations": variations.map { $0.rawValue },
            "icons": iconsData
        ]

        let sourceFile = try generateSourceCode(context: context)

        return (files: iconFiles + [sourceFile], warnings: ErrorGroup(all: warnings))
    }

    private func makeAndRegisterFileContents(
        variationsData: inout [String: URL],
        imagePack: ImagePack?,
        variation: IconVariation
    ) -> FileContents? {
        guard let imagePack, let icon = imagePack.images.first else { return nil }

        let fileName = imagePack.name.snakeCased() + "_\(variation.rawValue).svg"
        let destination = Destination(
            directory: output.iconsAssetsFolder,
            file: URL(string: fileName)!
        )

        let fileContents = FileContents(
            destination: destination,
            sourceURL: icon.url,
            scale: icon.scale.value,
            dark: false,
            isRTL: icon.isRTL
        )
        let codegenFileName = fileName + (output.useSvgVec ? ".vec" : "")
        variationsData[variation.rawValue] = output.relativeIconsPath.appendingPathComponent(
            codegenFileName,
            isDirectory: false
        )
        return fileContents
    }

    private func generateSourceCode(context: [String: Any]) throws -> FileContents {
        let env = makeEnvironment(templatesPath: output.templatesURL)
        let sourceCode = try env.renderTemplate(name: "icons.dart.stencil", context: context)
        let data = sourceCode.data(using: .utf8)!
        let destination = Destination(
            directory: output.outputFile.deletingLastPathComponent(),
            file: URL(string: output.outputFile.lastPathComponent)!
        )
        return FileContents(destination: destination, data: data)
    }
}
