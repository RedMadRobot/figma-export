import Foundation

struct Params: Decodable {

    struct Figma: Decodable {
        let teamId: String
        let projectId: String
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
            let assetsFolder: String
            let colorSwift: URL
            let nameStyle: NameStyle
        }
        
        struct Icons: Decodable {
            let assetsFolder: String
            let preservesVectorRepresentation: [String]?
            let nameStyle: NameStyle
        }

        struct Images: Decodable {
            let assetsFolder: String
            let nameStyle: NameStyle
        }
        
        let xcassetsPath: URL
        let colors: Colors
        let icons: Icons
        let images: Images
    }

    struct Android: Decodable {
        let mainRes: URL
    }

    let figma: Figma
    let common: Common?
    let ios: iOS?
    let android: Android?
}
