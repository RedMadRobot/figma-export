import Foundation

struct Params: Decodable {

    struct Figma: Decodable {
        let lightFileId: String
        let darkFileId: String?
    }
    
    struct Common: Decodable {
        struct Colors: Decodable {
            let nameValidateRegexp: String?
        }
        
        struct Icons: Decodable {
            let nameValidateRegexp: String?
            let figmaFrameName: String?
        }
        
        struct Images: Decodable {
            let nameValidateRegexp: String?
            let figmaFrameName: String?
        }
        
        let colors: Colors?
        let icons: Icons?
        let images: Images?
    }
    
    enum NameStyle: String, Decodable {
        case camelCase = "camelCase"
        case snakeCase = "snake_case"
    }
    
    enum VectorFormat: String, Decodable {
        case pdf
        case svg
    }
    
    struct iOS: Decodable {
        
        struct Colors: Decodable {
            let useColorAssets: Bool
            let assetsFolder: String?
            let nameStyle: NameStyle
            
            let colorSwift: URL?
            let swiftuiColorSwift: URL?
        }
        
        struct Icons: Decodable {
            let format: VectorFormat
            let assetsFolder: String
            let preservesVectorRepresentation: [String]?
            let nameStyle: NameStyle
            
            let imageSwift: URL?
            let swiftUIImageSwift: URL?
        }

        struct Images: Decodable {
            let assetsFolder: String
            let nameStyle: NameStyle
            
            let imageSwift: URL?
            let swiftUIImageSwift: URL?
        }
        
        struct Typography: Decodable {
            let fontSwift: URL?
            let swiftUIFontSwift: URL?
            let generateLabels: Bool
            let labelsDirectory: URL?
        }
        
        let xcodeprojPath: String
        let target: String
        let xcassetsPath: URL
        let xcassetsInMainBundle: Bool
        let colors: Colors
        let icons: Icons
        let images: Images
        let typography: Typography
    }

    struct Android: Decodable {
        struct Icons: Decodable {
            let output: String
        }
        struct Images: Decodable {
            enum Format: String, Decodable {
                case svg
                case png
                case webp
            }
            struct FormatOptions: Decodable {
                enum Encoding: String, Decodable {
                    case lossy
                    case lossless
                }
                let encoding: Encoding
                let quality: Int?
            }
            let output: String
            let format: Format
            let webpOptions: FormatOptions?
        }
        let mainRes: URL
        let icons: Icons?
        let images: Images?
    }

    let figma: Figma
    let common: Common?
    let ios: iOS?
    let android: Android?
}
