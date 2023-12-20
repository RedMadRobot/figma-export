import Foundation

extension Color {
    
    /// Creates a name from a hex or rgba value
    /// - Parameters:
    ///   - name:
    ///   - value:
    public init?(name: String, value: String) {
        if value.hasPrefix("#") {
            self.init(name: name, hex: value)
        } else if value.hasPrefix("rgba") {
            self.init(name: name, rgbaString: value)
        } else {
            return nil
        }
    }

    private init?(name: String, hex: String) {
        let r, g, b: Double
        let start = hex.index(hex.startIndex, offsetBy: hex.hasPrefix("#") ? 1 : 0)
        let hexColor = String(hex[start...])

        if hexColor.count == 6 {
            let scanner = Scanner(string: hexColor)
            var hexNumber: UInt64 = 0

            if scanner.scanHexInt64(&hexNumber) {
                r = Double((hexNumber & 0xff0000) >> 16) / 255
                g = Double((hexNumber & 0x00ff00) >> 8) / 255
                b = Double(hexNumber & 0x0000ff) / 255

                self.init(name: name, red: r, green: g, blue: b, alpha: 1)
                return
            }
        }

        return nil
    }

    private init?(name: String, rgbaString: String) {
        let components = rgbaString
            .replacingOccurrences(of: "rgba(", with: "")
            .replacingOccurrences(of: ")", with: "")
            .split(separator: ",")
            .compactMap { Double($0.trimmingCharacters(in: .whitespaces)) }

        guard components.count == 4 else { return nil }

        self.init(name: name, red: components[0] / 255, green: components[1] / 255, blue: components[2] / 255, alpha: components[3])
    }
}
