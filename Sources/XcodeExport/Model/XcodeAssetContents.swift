import FigmaExportCore

enum XcodeAssetIdiom: String, Encodable {
    case universal
    case iphone
    case ipad
    case mac
    case tv
    case watch
    case car
}

struct XcodeAssetContents: Encodable {
    struct Info: Encodable {
        let version = 1
        let author = "xcode"
    }
    struct Appearance: Encodable {
        let appearance: String
        let value: String
    }
    struct Components: Encodable {
        var red: String
        var alpha: String
        var green: String
        var blue: String
    }
    struct ColorInfo: Encodable {
        enum CodingKeys: String, CodingKey {
            case colorSpace = "color-space"
            case components
        }
        let colorSpace = "srgb"
        let components: Components
    }
    struct ColorData: Encodable {
        let idiom = "universal"
        var appearances: [Appearance]?
        var color: ColorInfo
    }
    struct ImageData: Encodable {
        let idiom: XcodeAssetIdiom
        var scale: String?
        var appearances: [Appearance]?
        let filename: String
    }
    
    struct Properties: Encodable {
        let templateRenderingIntent: String?
        let preservesVectorRepresentation: Bool?
        
        enum CodingKeys: String, CodingKey {
            case templateRenderingIntent = "template-rendering-intent"
            case preservesVectorRepresentation = "preserves-vector-representation"
        }

        init?(preserveVectorData: Bool?, renderMode: XcodeRenderMode?) {
            preservesVectorRepresentation = preserveVectorData == true ? true : nil
            
            if let renderMode = renderMode, (renderMode == .original || renderMode == .template) {
                templateRenderingIntent = renderMode.rawValue
            } else {
                templateRenderingIntent = nil
            }
            
            if preservesVectorRepresentation == nil && templateRenderingIntent == nil {
                return nil
            }
        }

    }
    
    let info = Info()
    let colors: [ColorData]?
    let images: [ImageData]?
    let properties: Properties?
    
    init(colors: [ColorData]) {
        self.colors = colors
        self.images = nil
        self.properties = nil
    }

    init(images: [ImageData], properties: Properties? = nil) {
        self.colors = nil
        self.images = images
        self.properties = properties
    }
}

extension XcodeAssetContents.Appearance {
    static var dark = Self(appearance: "luminosity", value: "dark")
    static var highContrast = Self(appearance: "contrast", value: "high")
}
