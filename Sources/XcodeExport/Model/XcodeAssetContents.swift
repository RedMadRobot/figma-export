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
        let author = "xcode"
        let version = 1
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
        var appearances: [Appearance]?
        var color: ColorInfo
        let idiom = "universal"
    }
    struct ImageData: Encodable {
        var appearances: [Appearance]?
        let filename: String
        let idiom: XcodeAssetIdiom
        let languageDirection: String?
        var scale: String?
        
        enum CodingKeys: String, CodingKey {
            case appearances
            case filename
            case idiom
            case languageDirection = "language-direction"
            case scale
        }
        
        init(appearances: [Appearance]?,
              filename: String,
              idiom: XcodeAssetIdiom,
              isRTL: Bool,
              scale: String?
        ) {
            self.appearances = appearances
            self.filename = filename
            self.idiom = idiom
            self.languageDirection = isRTL ? "left-to-right" : nil
            self.scale = scale
        }
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
            
            if let renderMode, (renderMode == .original || renderMode == .template) {
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
