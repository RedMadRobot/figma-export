import Foundation

extension Color {
    
    /// Creates a name from a hex or rgba value
    /// - Parameters:
    ///   - name:
    ///   - value:
    public init?(name: String, value: String) {
        guard let color = ColorDecoder.paintColor(fromString: value) else {
            return nil
        }
        
        self.init(name: name,
                  red: color.r,
                  green: color.g,
                  blue: color.b,
                  alpha: color.a)
    }
}

struct ColorDecoder {
    
    static func paintColor(fromString string: String) -> PaintColor? {
        if string.hasPrefix("#") {
            return paintColor(fromHex: string)
        } else if string.hasPrefix("rgba") {
            return paintColor(fromRgba: string)
        }
        return nil
    }
    
    private static func paintColor(fromHex hex: String) -> PaintColor? {
        let start = hex.index(hex.startIndex, offsetBy: hex.hasPrefix("#") ? 1 : 0)
        let hexColor = String(hex[start...])

        let scanner = Scanner(string: hexColor)
        var hexNumber: UInt64 = 0
        
        guard hexColor.count == 6, scanner.scanHexInt64(&hexNumber) else {
            return nil
        }
        
        return PaintColor(r: Double((hexNumber & 0xff0000) >> 16) / 255,
                          g: Double((hexNumber & 0x00ff00) >> 8) / 255,
                          b: Double(hexNumber & 0x0000ff) / 255,
                          a: 1)
    }
    
    private static func paintColor(fromRgba rgba: String) -> PaintColor? {
        let components = rgba
            .replacingOccurrences(of: "rgba(", with: "")
            .replacingOccurrences(of: ")", with: "")
            .split(separator: ",")
            .compactMap { Double($0.trimmingCharacters(in: .whitespaces)) }

        guard components.count == 4 else { return nil }

        return PaintColor(r: components[0] / 255,
                          g: components[1] / 255,
                          b: components[2] / 255,
                          a: components[3])
    }
    
    public struct PaintColor: Decodable {
        public let r, g, b, a: Double
    }
}
