
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
    struct DarkAppeareance: Encodable {
        let appearance = "luminosity"
        let value = "dark"
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
        var appearances: [DarkAppeareance]?
        var color: ColorInfo
    }
    struct ImageData: Encodable {
        let idiom: XcodeAssetIdiom
        var scale: String?
        var appearances: [DarkAppeareance]?
        let filename: String
    }
    
    struct TemplateProperties: Encodable {
        let templateRenderingIntent = "template"
        let preservesVectorRepresentation: Bool?
        
        enum CodingKeys: String, CodingKey {
            case templateRenderingIntent = "template-rendering-intent"
            case preservesVectorRepresentation = "preserves-vector-representation"
        }
    }
    
    let info = Info()
    let colors: [ColorData]?
    let images: [ImageData]?
    let properties: TemplateProperties?
    
    init(colors: [ColorData]) {
        self.colors = colors
        self.images = nil
        self.properties = nil
    }
    
    init(icons: [ImageData], preservesVectorRepresentation: Bool = false) {
        self.colors = nil
        self.images = icons
        if preservesVectorRepresentation {
            self.properties = TemplateProperties(preservesVectorRepresentation: true)
        } else {
            self.properties = TemplateProperties(preservesVectorRepresentation: nil)
        }
    }

    init(images: [ImageData]) {
        self.colors = nil
        self.images = images
        self.properties = nil
    }

    init(images: [ImageData], properties: TemplateProperties? = nil) {
        self.colors = nil
        self.images = images
        self.properties = properties
    }
}
