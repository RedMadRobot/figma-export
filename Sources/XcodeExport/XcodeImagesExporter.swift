import Foundation
import FigmaExportCore

final public class XcodeImagesExporter: XcodeImagesExporterBase {

    public func export2(assets: [AssetPair<ImagePack>], append: Bool) throws -> [FileContents] {
        // Generate assets
        let assetsFolderURL = output.assetsFolderURL

        // Generate metadata (Assets.xcassets/Illustrations/Contents.json)
        let contentsFile = XcodeEmptyContents().makeFileContents(to: assetsFolderURL)

        let imageAssetsFiles = try assets.flatMap { pair -> [FileContents] in
            try pair.makeFileContents(to: assetsFolderURL)
        }

        // Generate extensions
        let imageNames = assets.map { $0.light.name }
        let extensionFiles = try generateExtensions(names: imageNames, append: append)

        return [contentsFile] + imageAssetsFiles + extensionFiles
    }

    public func export(assets: [AssetPair<ImagePack>], append: Bool) throws -> [FileContents] {
        var files: [FileContents] = []

        // Assets.xcassets/Illustrations/Contents.json
        files.append(makeEmptyContentsJson())

        // For each pair...
        try assets.forEach { pair in
            guard let pair = pair.pairForXcode() else {
                return
            }
            let name = pair.light.name

            // Create imageset directory
            let imageDirURL = output.assetsFolderURL.appendingPathComponent("\(name).imageset")

            // Add image files to the directory
            files.append(contentsOf: saveImagePair(pair, to: imageDirURL))

            // Add link to image files to
            // Assets.xcassets/Illustrations/***.imageset/Contents.json
            let contents = XcodeAssetContents(images: imageDataFromPair(pair))

            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            let data = try encoder.encode(contents)
            let fileURL = URL(string: "Contents.json")!
            files.append(FileContents(
                destination: Destination(directory: imageDirURL, file: fileURL),
                data: data
            ))
        }

        let imageNames = assets.map { $0.light.name }

        let extensionFiles = try generateExtensions(names: imageNames, append: append)
        files.append(contentsOf: extensionFiles)

        return files
    }

    private func makeEmptyContentsJson() -> FileContents {
        let contentsJson = XcodeEmptyContents()
        let destination = Destination(directory: output.assetsFolderURL, file: contentsJson.fileURL)

        return FileContents(
            destination: destination,
            data: contentsJson.data
        )
    }


    private func makeFileURL(for image: Image, scale: Scale, dark: Bool = false) -> URL {
        var urlString = image.name

        if let idiom = image.idiom, !idiom.isEmpty {
            urlString.append("~\(idiom)")
        }

        if dark {
            urlString.append("D")
        } else {
            urlString.append("L")
        }

        let scaleValue = scale.value
        if let scaleString = normalizeScale(scaleValue) {
            urlString.append("@\(scaleString)x")
        }

        return URL(string: urlString)!.appendingPathExtension(image.format)
    }

    /// Extract all the images from AssetPair to specific directory
    private func saveImagePair(_ pair: AssetPair<ImagePack>, to directory: URL) -> [FileContents] {
        if let dark = pair.dark {
            return
                saveImagePack(pack: pair.light, to: directory) +
                saveImagePack(pack: dark, to: directory, dark: true)
        } else {
            return saveImagePack(pack: pair.light, to: directory)
        }
    }

    private func saveImagePack(pack: ImagePack, to directory: URL, dark: Bool = false) -> [FileContents] {
        pack.images.map { saveImage($0, to: directory, scale: $0.scale, dark: dark) }
    }

    private func saveImage(_ image: Image, to directory: URL, scale: Scale, dark: Bool) -> FileContents {

        let imageURL = makeFileURL(for: image, scale: scale, dark: dark)
        let destination = Destination(directory: directory, file: imageURL)

        return FileContents(
            destination: destination,
            sourceURL: image.url
        )
    }

    // Link all the images with Contents.json
    private func imageDataFromPair(_ pair: AssetPair<ImagePack>) -> [XcodeAssetContents.ImageData] {
        if let dark = pair.dark {
            return
                imageDataFromPack(pair.light) +
                imageDataFromPack(dark, dark: true)

        } else {
            return imageDataFromPack(pair.light)
        }
    }

    private func imageDataFromPack(_ pack: ImagePack, dark: Bool = false) -> [XcodeAssetContents.ImageData] {
        pack.images.map { imageDataForImage($0, scale: $0.scale, dark: dark) }
    }

    private func imageDataForImage(_ image: Image, scale: Scale, dark: Bool) -> XcodeAssetContents.ImageData {

        var appearance: [XcodeAssetContents.DarkAppeareance]?
        if dark {
            appearance = [XcodeAssetContents.DarkAppeareance()]
        }

        let imageURL = makeFileURL(for: image, scale: scale, dark: dark)

        let idiom = image.idiom.flatMap { XcodeAssetIdiom(rawValue: $0) } ?? .universal

        return XcodeAssetContents.ImageData(
            idiom: idiom,
            scale: scale.string,
            appearances: appearance,
            filename: imageURL.absoluteString
        )
    }

    /// Trims trailing zeros from scale value 1.0 → 1, 1.5 → 1.5, 3.0 → 3
    private func normalizeScale(_ scale: Double) -> String? {
        let formatter = NumberFormatter()
        formatter.decimalSeparator = "."
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: scale))
    }

}

private extension AssetPair where AssetType == ImagePack {

    func pairForXcode() -> AssetPair<AssetType>? {
        guard let light = light.packForXcode() else {
            return nil
        }
        return AssetPair(light: light, dark: dark?.packForXcode())
    }

    func makeFileContents(to directory: URL) throws -> [FileContents] {
        let lightFiles = try light.makeFileContents(to: directory, preservesVector: nil, appearance: .light)
        let darkFiles = try dark?.makeFileContents(to: directory, preservesVector: nil, appearance: .dark) ?? []
        return lightFiles + darkFiles
    }

}
