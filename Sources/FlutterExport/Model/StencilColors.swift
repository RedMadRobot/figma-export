import Foundation

struct ColorWithVariations {
    struct Variation {
        let a, r, g, b: Int
    }

    let name: String
    let variations: [String: Variation]
}

struct SimpleColor {
    let name: String
    let a, r, g, b: Int
}
