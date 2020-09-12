import Foundation
import FigmaExportCore

final public class XcodeImagesExporter: XcodeImagesExporterBase {

    public func export(assets: [AssetPair<ImagePack>], append: Bool) throws -> [FileContents] {
        var files: [FileContents] = []

        // Assets.xcassets/Illustrations/Contents.json
        files.append(makeEmptyContentsJson())

        // For each pair...
        assets.forEach { pair in
            let name = pair.light.name

            // Create imageset directory
            let imageDirURL = output.assetsFolderURL.appendingPathComponent("\(name).imageset")

            // Add image files to the directory
            files.append(contentsOf: self.saveImagePair(pair, to: imageDirURL))

            // Add link to image files to
            // Assets.xcassets/Illustrations/***.imageset/Contents.json
            let contents = XcodeAssetContents(images: imageDataFromPair(pair))

            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try! encoder.encode(contents)
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


    private func makeFileURL(for image: Image, scale: Int?, dark: Bool = false) -> URL {
        var urlString = image.name
        if dark {
            urlString.append("D")
        } else {
            urlString.append("L")
        }
        if let scale = scale {
            urlString.append("@\(scale)x")
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
        switch pack {
        case .singleScale(let image):
            return [saveImage(image, to: directory, dark: dark)]
        case let .individualScales(x1, x2, x3):
            return [
                saveImage(x1, to: directory, scale: 1, dark: dark),
                saveImage(x2, to: directory, scale: 2, dark: dark),
                saveImage(x3, to: directory, scale: 3, dark: dark)
            ]
        }
    }


    private func saveImage(_ image: Image, to directory: URL, scale: Int? = nil, dark: Bool) -> FileContents {

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
        switch pack {
        case .singleScale(let image):
            return [imageDataForImage(image, dark: dark)]
        case let .individualScales(x1, x2, x3):
            return [
                imageDataForImage(x1, scale: 1, dark: dark),
                imageDataForImage(x2, scale: 2, dark: dark),
                imageDataForImage(x3, scale: 3, dark: dark)
            ]
        }
    }

    private func imageDataForImage(_ image: Image, scale: Int? = nil, dark: Bool) -> XcodeAssetContents.ImageData {

        var appearance: [XcodeAssetContents.DarkAppeareance]? = nil
        if dark {
            appearance = [XcodeAssetContents.DarkAppeareance()]
        }

        let imageURL = makeFileURL(for: image, scale: scale, dark: dark)

        return XcodeAssetContents.ImageData(
            scale: scale == nil ? nil : "\(scale!)x",
            appearances: appearance,
            filename: imageURL.absoluteString
        )
    }
}
