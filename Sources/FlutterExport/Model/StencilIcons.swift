import Foundation

enum IconVariation: String, CaseIterable, Comparable {
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
        if let lhsIndex = IconVariation.allCases.firstIndex(of: lhs),
           let rhsIndex = IconVariation.allCases.firstIndex(of: rhs) {
            lhsIndex < rhsIndex
        } else {
            false
        }
    }
}

struct IconData {
    let name: String
    /// [Variation: Path], ex. ["light": "icons/ic_arrow_light.svg"]
    let variations: [String: URL]
}
