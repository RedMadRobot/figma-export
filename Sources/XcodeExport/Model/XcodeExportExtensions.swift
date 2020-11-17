import FigmaExportCore
import Foundation

enum Appearance {
    case light
    case dark
}

// MARK: Scale

extension Scale {

    var string: String? {
        switch self {
        case .all:
            return nil
        case .individual(let value):
            guard let normalized = normalizeScale(value) else {
                return nil
            }
            return "\(normalized)x"
        }
    }

    /// Trims trailing zeros from scale value 1.0 → 1, 1.5 → 1.5, 3.0 → 3
    private func normalizeScale(_ scale: Double) -> String? {
        let formatter = NumberFormatter()
        formatter.decimalSeparator = "."
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: scale))
    }

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
        var xcodeImagePack = self
        xcodeImagePack.images = images.filter { $0.isValidForXcode(scale: $0.scale) }
        return xcodeImagePack
    }

    func makeFileContents(to directory: URL, preservesVector: Bool?, appearance: Appearance? = nil) throws -> [FileContents] {
        let properties = XcodeAssetContents.TemplateProperties(preservesVectorRepresentation: preservesVector)

        return try packForXcode()
            .flatMap { imagePack -> [FileContents] in
                let name = imagePack.name
                let dirURL = directory.appendingPathComponent("\(name).imageset")
                
                let assetsContents = imagePack.makeXcodeAssetContentsImageData(appearance: appearance)
                let contentsFileContents = try XcodeAssetContents(
                    images: assetsContents,
                    properties: properties
                ).makeFileContents(to: dirURL)
                
                let files = imagePack.makeImageFileContents(to: dirURL, appearance: appearance)
                
                return files + [contentsFileContents]
            } ?? []
    }

    func makeImageFileContents(to directory: URL, appearance: Appearance? = nil) -> [FileContents] {
        images.map { $0.makeFileContents(to: directory, appearance: appearance) }
    }

    func makeXcodeAssetContentsImageData(appearance: Appearance? = nil) -> [XcodeAssetContents.ImageData] {
        images.map { $0.makeXcodeAssetContentsImageData(scale: $0.scale, appearance: appearance) }
    }

}

// MARK: AssetPair

extension AssetPair where AssetType == ImagePack {

    func makeFileContents(to directory: URL, preservesVector: Bool?) throws -> [FileContents] {
        let name = light.name
        let dirURL = directory.appendingPathComponent("\(name).imageset")

        let lightPack = light.packForXcode()
        let darkPack = dark?.packForXcode()

        let lightFiles = lightPack?.makeImageFileContents(to: dirURL, appearance: .light) ?? []
        let darkFiles = darkPack?.makeImageFileContents(to: dirURL, appearance: .dark) ?? []

        let lightAssetContents = lightPack?.makeXcodeAssetContentsImageData(appearance: .light) ?? []
        let darkAssetContents = darkPack?.makeXcodeAssetContentsImageData(appearance: .dark) ?? []

        let properties = XcodeAssetContents.TemplateProperties(preservesVectorRepresentation: preservesVector)

        let contentsFileContents = try XcodeAssetContents(
            images: lightAssetContents + darkAssetContents,
            properties: properties
        ).makeFileContents(to: dirURL)

        return [contentsFileContents] + lightFiles + darkFiles
    }

}

// MARK: Image

extension Image {

    func makeFileContents(to directory: URL, appearance: Appearance? = nil) -> FileContents {
        let fileURL = makeFileURL(scale: scale, appearance: appearance)
        let destination = Destination(directory: directory, file: fileURL)
        return FileContents(destination: destination, sourceURL: url)
    }

    func makeXcodeAssetContentsImageData(scale: Scale, appearance: Appearance? = nil) -> XcodeAssetContents.ImageData {
        let filename = makeFileURL(scale: scale, appearance: appearance).absoluteString
        let xcodeIdiom = idiom.flatMap { XcodeAssetIdiom(rawValue: $0) } ?? .universal
        let appearances = appearance.flatMap { $0 == .dark ? [XcodeAssetContents.DarkAppeareance()] : nil }
        let scaleString = scale.string

        return XcodeAssetContents.ImageData(
            idiom: xcodeIdiom,
            scale: scaleString,
            appearances: appearances,
            filename: filename
        )
    }

    private func makeFileURL(scale: Scale, appearance: Appearance? = nil) -> URL {
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

        if let scaleString = scale.string {
            urlString.append("@\(scaleString)")
        }

        return URL(string: urlString)!.appendingPathExtension(format)
    }

    fileprivate func isValidForXcode(scale: Scale) -> Bool {
        switch scale {
        case .all:
            return true
        case .individual(let value):
            guard let idiom = idiom, !idiom.isEmpty else {
                return true
            }

            guard let device = XcodeAssetIdiom(rawValue: idiom) else {
                return false
            }

            switch device {
            case .iphone:
                return [1, 2, 3].contains(value)
            case .ipad, .tv, .mac:
                return [1, 2].contains(value)
            case .watch:
                return [2].contains(value)
            case .car:
                return [2, 3].contains(value)
            default:
                return true
            }
        }
    }

}
