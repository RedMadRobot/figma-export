import FigmaExportCore
import Foundation

enum Appearance {
    case light
    case dark
}

// MARK: XcodeEmptyContents

extension XcodeEmptyContents {

    func makeFileContents(to directory: URL) -> FileContents {
        let destination = Destination(directory: directory, file: fileURL)
        return FileContents(destination: destination, data: data)
    }

}

// MARK: XcodeAssetContents

extension XcodeAssetContents {

    func makeFileContents(to directory: URL) throws -> FileContents {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted

        let data = try encoder.encode(self)
        let fileURL = URL(string: "Contents.json")!

        return FileContents(
            destination: Destination(directory: directory, file: fileURL),
            data: data
        )
    }

}

// MARK: ImagePack

extension ImagePack {

    func packForXcode() -> ImagePack? {
        switch self {
        case .singleScale(let image):
            guard image.isValidForXcode(scale: image.scale) else {
                return nil
            }
            return self
        case .individualScales(let images):
            let validImages = images.reduce(into: [Scale: Image]()) { result, info in
                let (scale, image) = info
                guard image.isValidForXcode(scale: scale) else {
                    return
                }
                result[scale] = image
            }
            return .individualScales(validImages)
        case .images(let images):
            return .images(images.filter { $0.isValidForXcode(scale: $0.scale) })
        }
    }

    func makeFileContents(to directory: URL, preservesVector: Bool?) throws -> [FileContents] {
        try packForXcode()
            .flatMap { imagePack -> [FileContents] in
                let name = imagePack.name
                let dirURL = directory.appendingPathComponent("\(name).imageset")

                let properties = { () -> XcodeAssetContents.TemplateProperties? in
                    if let preservesVector = preservesVector {
                       return XcodeAssetContents.TemplateProperties(preservesVectorRepresentation: preservesVector ? true : nil)
                    } else {
                        return nil
                    }
                }()

                let contentsFileContents = try XcodeAssetContents(
                    images: imagePack.makeXcodeAssetContentsImageData(),
                    properties: properties
                ).makeFileContents(to: dirURL)

                let imagesFileContents = imagePack.makeImageFileContents(to: dirURL)

                return imagesFileContents + [contentsFileContents]
            } ?? []
    }

    func makeImageFileContents(to directory: URL, appearance: Appearance? = nil) -> [FileContents] {
        switch self {
        case .singleScale(let image):
            return [image.makeFileContents(to: directory, appearance: appearance)]
        case .individualScales(let images):
            return images.map { scale, image -> FileContents in
                image.makeFileContents(to: directory, appearance: appearance)
            }
        case .images(let images):
            return images.map { $0.makeFileContents(to: directory, appearance: appearance) }
        }
    }

    func makeXcodeAssetContentsImageData() -> [XcodeAssetContents.ImageData] {
        switch self {
        case .singleScale(let image):
            return [image.makeXcodeAssetContentsImageData(scale: image.scale)]
        case .individualScales(let images):
            return images.map { $1.makeXcodeAssetContentsImageData(scale: $0) }
        case .images(let images):
            return images.map { $0.makeXcodeAssetContentsImageData(scale: $0.scale) }
        }
    }

}

// MARK: Image

extension Image {

    func isValidForXcode(scale: Double) -> Bool {
        guard let idiom = idiom, !idiom.isEmpty else {
            return true
        }

        guard let device = XcodeAssetIdiom(rawValue: idiom) else {
            return false
        }

        switch device {
        case .iphone:
            return [1, 2, 3].contains(scale)
        case .ipad, .tv, .mac:
            return [1, 2].contains(scale)
        case .watch:
            return [2].contains(scale)
        case .car:
            return [2, 3].contains(scale)
        default:
            return true
        }
    }

    func makeFileContents(to directory: URL, appearance: Appearance? = nil) -> FileContents {
        let fileURL = makeFileURL(scale: scale, appearance: appearance)
        let destination = Destination(directory: directory, file: fileURL)
        return FileContents(destination: destination, sourceURL: url)
    }

    func makeXcodeAssetContentsImageData(scale: Double?) -> XcodeAssetContents.ImageData {
        let filename = makeFileURL(scale: scale).absoluteString
        let xcodeIdiom = idiom.flatMap { XcodeAssetIdiom(rawValue: $0) } ?? .universal
        return XcodeAssetContents.ImageData(idiom: xcodeIdiom, filename: filename)
    }

    func makeFileURL(scale: Double?, appearance: Appearance? = nil) -> URL {
        var urlString = name

        if let idiom = idiom, !idiom.isEmpty {
            urlString.append("~\(idiom)")
        }

        switch appearance {
        case .light:
            urlString.append("L")
        case .dark:
            urlString.append("D")
        default:
            break
        }

        if let scale = scale, let scaleString = normalizeScale(scale), scaleString != "1" {
            urlString.append("@\(scaleString)x")
        }

        return URL(string: urlString)!.appendingPathExtension(format)
    }

    /// Trims trailing zeros from scale value 1.0 → 1, 1.5 → 1.5, 3.0 → 3
    private func normalizeScale(_ scale: Double) -> String? {
        let formatter = NumberFormatter()
        formatter.decimalSeparator = "."
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: scale))
    }

}
