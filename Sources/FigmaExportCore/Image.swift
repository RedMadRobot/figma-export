import Foundation

public struct Image: Asset {

    public var name: String
    public let scale: Double
    public let format: String
    public let url: URL
    public let idiom: String?

    public var platform: Platform?

    public init(name: String, scale: Double = 1, platform: Platform? = nil, idiom: String? = nil, url: URL, format: String) {
        self.name = name
        self.scale = scale
        self.platform = platform
        self.url = url
        self.idiom = idiom
        self.format = format
    }

    // MARK: Hashable

    public static func == (lhs: Image, rhs: Image) -> Bool {
        return lhs.name == rhs.name
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
}

public enum ImagePack: Asset {

    public typealias Scale = Double
    
    case singleScale(Image)
    case individualScales([Scale: Image])

    public var single: Image {
        switch self {
        case .singleScale(let image):
            return image
        case .individualScales:
            fatalError("Unable to extract image from image pack")
        }
    }

    public var name: String {
        get {
            switch self {
            case .singleScale(let image):
                return image.name
            case .individualScales(let images):
                return images.first!.value.name
            }
        }
        set {
            switch self {
            case .singleScale(var image):
                image.name = newValue
                self = .singleScale(image)
            case .individualScales(var images):
                for key in images.keys {
                    images[key]?.name = newValue
                }
                self = .individualScales(images)
            }
        }
    }

    public var platform: Platform? {
        switch self {
        case .singleScale(let image):
            return image.platform
        case .individualScales(let images):
            return images.first?.value.platform
        }
    }
}
