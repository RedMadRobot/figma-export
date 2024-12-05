import Foundation

struct ColorWithVariations {
    struct Variation {
        let a, r, g, b: Int
        let hex: String

        init(a: Int, r: Int, g: Int, b: Int) {
            self.a = a
            self.r = r
            self.g = g
            self.b = b
            hex = argbToHex(a: a, r: r, g: g, b: b)
        }
    }

    let name: String
    let variations: [String: Variation]
}

struct SimpleColor {
    let name: String
    let a, r, g, b: Int
    let hex: String

    init(name: String, a: Int, r: Int, g: Int, b: Int) {
        self.name = name
        self.a = a
        self.r = r
        self.g = g
        self.b = b
        hex = argbToHex(a: a, r: r, g: g, b: b)
    }
}

private func argbToHex(a: Int, r: Int, g: Int, b: Int) -> String {
    "0x"
    + String(format:"%02X", a)
    + String(format:"%02X", r)
    + String(format:"%02X", g)
    + String(format:"%02X", b)
}
