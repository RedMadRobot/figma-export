import Foundation

public enum Scale {
    case all
    case individual(_ value: Double)

    public var value: Double {
        switch self {
        case .all:
            return 1
        case .individual(let value):
            return value
        }
    }
}

public struct Image: Asset {

    public var name: String
    public let scale: Scale
    public let format: String
    public let url: URL
    public let idiom: String?

    public var platform: Platform?

    public init(name: String, scale: Scale = .all, platform: Platform? = nil, idiom: String? = nil, url: URL, format: String) {
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

public struct ImagePack: Asset {
    public var images: [Image]
    public var name: String {
        didSet {
            images = images.map { image -> Image in
                var newImage = image
                newImage.name = name
                return newImage
            }
        }
    }
    public var platform: Platform?

    public init(name: String, images: [Image], platform: Platform? = nil) {
        self.name = name
        self.images = images
        self.platform = platform
    }

    public init(image: Image, platform: Platform? = nil) {
        self.name = image.name
        self.images = [image]
        self.platform = platform
    }

}
