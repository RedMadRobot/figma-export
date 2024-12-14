import Foundation

enum IconVariation: String {
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

struct IconData {
    let name: String
    /// [Variation: Path], ex. ["light": "icons/ic_arrow_light.svg"]
    let variations: [String: URL]
}
