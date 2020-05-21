import Foundation

public struct Image: Asset {
    
    public var name: String
    public let format: String
    public let url: URL
    public var platform: Platform?
    
    public init(name: String, platform: Platform? = nil, url: URL, format: String) {
        self.name = name
        self.platform = platform
        self.url = url
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

    case singleScale(Image)
    case individualScales(x1: Image, x2: Image, x3: Image)

    public var single: Image {
        switch self {
        case .singleScale(let image):
            return image
        case .individualScales(_, _, _):
            fatalError("Unable to extract image from image pack")
        }
    }

    public var name: String {
        get {
            switch self {
            case .singleScale(let image):
                return image.name
            case .individualScales(let image, _, _):
                return image.name
            }
        }
        set {
            switch self {
            case .singleScale(var image):
                image.name = newValue
                self = .singleScale(image)
            case var .individualScales(x1, x2, x3):
                x1.name = newValue
                x2.name = newValue
                x3.name = newValue
                self = .individualScales(x1: x1, x2: x2, x3: x3)
            }
        }
    }

    public var platform: Platform? {
        switch self {
        case .singleScale(let image):
            return image.platform
        case .individualScales(let image, _, _):
            return image.platform
        }
    }
}
