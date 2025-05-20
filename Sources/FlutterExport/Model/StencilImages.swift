import Foundation

enum ImageVariation: String, CaseIterable, Comparable {
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

    static func < (lhs: Self, rhs: Self) -> Bool {
        if let lhsIndex = ImageVariation.allCases.firstIndex(of: lhs),
           let rhsIndex = ImageVariation.allCases.firstIndex(of: rhs) {
            lhsIndex < rhsIndex
        } else {
            false
        }
    }
}

struct ImageData {
    let name: String
    /// [Variation: Path], ex. ["light": "images/arrow_light.webp"]
    let variations: [String: URL]
}
