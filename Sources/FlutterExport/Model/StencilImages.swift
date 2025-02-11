import Foundation

enum ImageVariation: String {
    case light, dark, lightHighContrast, darkHighContrast

    var capitalized: String {
        switch self {
        case .light:
            "Light"
        case .dark:
            "Dark"
        case .lightHighContrast:
            "LightHighContrast"
        case .darkHighContrast:
            "DarkHighContrast"
        }
    }
}

struct ImageData {
    let name: String
    /// [Variation: Path], ex. ["light": "images/arrow_light.webp"]
    let variations: [String: URL]
}
