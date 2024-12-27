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
        var variations: [IconVariation] = [.light]
        if icons.first?.dark?.images.first != nil {
            variations.append(.dark)
        }
        if icons.first?.lightHC?.images.first != nil {
            variations.append(.lightHighContrast)
        }
        if icons.first?.darkHC?.images.first != nil {
            variations.append(.darkHighContrast)
        }
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
                    guard let file = makeAndRegisterFileContents(
                        variationsData: &variationsData,
                        imagePack: icon.dark,
                        variation: .dark
                    ) else {
                        warnings.append(Error.unspecifiedVariation(variation.rawValue, icon.light.name))
                        return []
                    }
                    files.append(file)
                case .lightHighContrast:
                    guard let file = makeAndRegisterFileContents(
                        variationsData: &variationsData,
                        imagePack: icon.lightHC,
                        variation: .lightHighContrast
                    ) else {
                        warnings.append(Error.unspecifiedVariation(variation.rawValue, icon.light.name))
                        return []
                    }
                    files.append(file)
                case .darkHighContrast:
                    guard let file = makeAndRegisterFileContents(
                        variationsData: &variationsData,
                        imagePack: icon.darkHC,
                        variation: .darkHighContrast
                    ) else {
                        warnings.append(Error.unspecifiedVariation(variation.rawValue, icon.light.name))
                        return []
                    }
                    files.append(file)
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

        let fileName = imagePack.name + "_\(variation.rawValue).svg\(output.useSvgVec ? ".vec" : "")"
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
        variationsData[variation.rawValue] = output.relativeIconsPath.appendingPathComponent(fileName, isDirectory: false)
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
