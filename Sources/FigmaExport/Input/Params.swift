import Foundation

struct Params: Decodable {

    struct Figma: Decodable {
        let lightFileId: String
        let darkFileId: String?
    }
    
    struct Common: Decodable {
        struct Colors: Decodable {
            let nameValidateRegexp: String
        }
        
        struct Icons: Decodable {
            let nameValidateRegexp: String
        }
        
        struct Images: Decodable {
            let nameValidateRegexp: String
        }
        
        let colors: Colors
        let icons: Icons
        let images: Images
    }
    
    enum NameStyle: String, Decodable {
        case camelCase = "camelCase"
        case snakeCase = "snake_case"
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
            let fontExtensionDirectory: String
            let generateLabels: Bool
            let labelsDirectory: String
        }
        
        let xcassetsPath: URL
        let colors: Colors
        let icons: Icons
        let images: Images
        let typography: Typography
    }

    struct Android: Decodable {
        let mainRes: URL
    }

    let figma: Figma
    let common: Common?
    let ios: iOS?
    let android: Android?
}
