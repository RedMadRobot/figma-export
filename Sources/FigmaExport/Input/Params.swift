import Foundation
import FigmaExportCore

extension NameStyle: Decodable {}

struct Params: Decodable {

    struct Figma: Decodable {
        let lightFileId: String
        let darkFileId: String?
    }
    
    struct Common: Decodable {
        struct Colors: Decodable {
            let nameValidateRegexp: String?
            let nameReplaceRegexp: String?
            let ignoreBadNames: Bool?
        }
        
        struct Icons: Decodable {
            let nameValidateRegexp: String?
            let figmaFrameName: String?
            let nameReplaceRegexp: String?
            let ignoreBadNames: Bool?
        }
        
        struct Images: Decodable {
            let nameValidateRegexp: String?
            let figmaFrameName: String?
            let nameReplaceRegexp: String?
            let ignoreBadNames: Bool?
        }
        
        let colors: Colors?
        let icons: Icons?
        let images: Images?
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
            let nameStyle: NameStyle

            let format: VectorFormat
            let assetsFolder: String

            let preservesVectorRepresentation: Bool
            let preservesVectorRepresentationIcons: [String]?

            let renderIntent: RenderIntent?
            let renderAsOriginalIcons: [String]?
            let renderAsTemplateIcons: [String]?

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
            let typographyVersion: Int?
            let stylesDirectory: URL?
            let swiftUIFontSwift: URL?
            let generateComponents: Bool
            let componentsDirectory: URL?
        }
        
        let xcodeprojPath: String
        let xcodeprojMainGroupName: String?
        let target: String
        let xcassetsPathImages: URL
        let xcassetsPathColors: URL
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

        struct Typography: Decodable {

            let output: String
            let attributes: [TypographyAttributes]?
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

        struct Colors: Decodable {
            let output: String
        }

        let mainRes: URL
        let icons: Icons?
        let images: Images?
        let typography: Typography?
        let colors: Colors?
    }

    let figma: Figma
    let common: Common?
    let ios: iOS?
    let android: Android?
}
