import Foundation
import FigmaExportCore

public final class FlutterImagesExporter: FlutterExporterBase {
    enum Error: Swift.Error, LocalizedError {
        case unspecifiedVariation(String, String)

        var errorDescription: String? {
            switch self {
            case let .unspecifiedVariation(variation, image):
                "Variation \"\(variation)\" is not specified for the image \"\(image)\". Skipping \"\(image)\"."
            }
        }
    }

    let output: FlutterImagesOutput

    public init(output: FlutterImagesOutput) {
        self.output = output
    }

    public func export(images: [AssetPair<ImagePack>]) throws -> (files: [FileContents], warnings: ErrorGroup) {
        var usedVariations: Set<ImageVariation> = [.light]
        for image in images {
            if usedVariations.count == ImageVariation.allCases.count {
                break
            }
            if image.dark != nil { usedVariations.insert(.dark) }
            if image.lightHC != nil { usedVariations.insert(.lightHighContrast) }
            if image.darkHC != nil { usedVariations.insert(.darkHighContrast) }
        }
        let variations = Array(usedVariations).sorted()
        var imagesData: [ImageData] = []
        var warnings: [Swift.Error] = []
        let imageFiles = images.flatMap { image -> [FileContents] in
            do {
                try validateName(image.light.name)
            } catch {
                warnings.append(error)
                return []
            }
            var variationsData: [String: URL] = [:]
            var files: [FileContents] = []
            for variation in variations {
                switch variation {
                case .light:
                    guard let imageFiles = makeAndRegisterFileContents(
                        variationsData: &variationsData,
                        imagePack: image.light,
                        variation: .light
                    ) else {
                        warnings.append(Error.unspecifiedVariation(variation.rawValue, image.light.name))
                        return []
                    }
                    files.append(contentsOf: imageFiles)
                case .dark:
                    if let imageFiles = makeAndRegisterFileContents(
                        variationsData: &variationsData,
                        imagePack: image.dark,
                        variation: .dark
                    ) {
                        files.append(contentsOf: imageFiles)
                    }
                case .lightHighContrast:
                    if let imageFiles = makeAndRegisterFileContents(
                        variationsData: &variationsData,
                        imagePack: image.lightHC,
                        variation: .lightHighContrast
                    ) {
                        files.append(contentsOf: imageFiles)
                    }
                case .darkHighContrast:
                    if let imageFiles = makeAndRegisterFileContents(
                        variationsData: &variationsData,
                        imagePack: image.darkHC,
                        variation: .darkHighContrast
                    ) {
                        files.append(contentsOf: imageFiles)
                    }
                }
            }
            imagesData.append(ImageData(name: image.light.name.lowerCamelCased(), variations: variationsData))
            return files
        }

        let context: [String: Any] = [
            "imagesClassName": output.imagesClassName,
            "baseAssetClass": output.baseAssetClass,
            "baseAssetClassFilePath": output.baseAssetClassFilePath,
            "variations": variations.map { $0.rawValue },
            "images": imagesData
        ]

        let sourceFile = try generateSourceCode(context: context)

        return (files: imageFiles + [sourceFile], warnings: ErrorGroup(all: warnings))
    }

    private func makeAndRegisterFileContents(
        variationsData: inout [String: URL],
        imagePack: ImagePack?,
        variation: ImageVariation
    ) -> [FileContents]? {
        guard let imagePack, !imagePack.images.isEmpty else { return nil }

        let codegenFileName = imagePack.name.snakeCased() + "_\(variation.rawValue).\(output.format)"
        variationsData[variation.rawValue] = output.relativeImagesPath.appendingPathComponent(
            codegenFileName,
            isDirectory: false
        )

        let realFileName = imagePack.name.snakeCased() + "_\(variation.rawValue).\(imagePack.images.first?.format ?? "")"

        let allFileContents = imagePack.images.compactMap { image -> FileContents? in
            guard output.scales.contains(image.scale.value) else { return nil }

            var directory = output.imagesAssetsFolder
            // https://docs.flutter.dev/ui/assets/assets-and-images#resolution-aware
            if image.scale.value != 1 {
                let scaleString = String(format: "%.1f", image.scale.value) + "x"
                directory.appendPathComponent(scaleString, isDirectory: true)
            }
            let destination = Destination(
                directory: directory,
                file: URL(string: realFileName)!
            )
            let fileContents = FileContents(
                destination: destination,
                sourceURL: image.url,
                scale: image.scale.value,
                dark: false,
                isRTL: image.isRTL
            )
            return fileContents
        }
        return allFileContents
    }

    private func generateSourceCode(context: [String: Any]) throws -> FileContents {
        let env = makeEnvironment(templatesPath: output.templatesURL)
        let sourceCode = try env.renderTemplate(name: "images.dart.stencil", context: context)
        let data = sourceCode.data(using: .utf8)!
        let destination = Destination(
            directory: output.outputFile.deletingLastPathComponent(),
            file: URL(string: output.outputFile.lastPathComponent)!
        )
        return FileContents(destination: destination, data: data)
    }
}
