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

        struct Typography: Decodable {
            let nameValidateRegexp: String?
            let nameReplaceRegexp: String?
            let weightToFontNameMappings: [String: [String: String]]?
        }

        struct Dimensions: Decodable {
            let figmaFrameName: String?
            let componentNames: [String]?
        }
        
        let colors: Colors?
        let typography: Typography?
        let icons: Icons?
        let images: Images?
        let dimensions: Dimensions?
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

            enum Format: String, Decodable {
                case swift
                case json
            }

            let typographyVersion: Int?
            let stylesDirectory: URL?
            let stylesFileName: String?
            let format: Format?
            let swiftUIFontSwift: URL?
            let generateComponents: Bool
            let componentsDirectory: URL?
            
        }

        struct Dimensions: Decodable {
            let dimensionsDirectory: URL
            let dimensionsFileName: String?
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
        let dimensions: Dimensions?
    }

    struct Android: Decodable {
        struct Icons: Decodable {
            let output: String
        }

        struct Typography: Decodable {

            let output: String
            let colorsMatchRegexp: String?
            let strongMatchWithColors: Bool?
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

        struct Dimensions: Decodable {
            let output: String?
        }

        let mainRes: URL
        let icons: Icons?
        let images: Images?
        let typography: Typography?
        let colors: Colors?
        let dimensions: Dimensions?
    }

    let figma: Figma
    let common: Common?
    let ios: iOS?
    let android: Android?
}
