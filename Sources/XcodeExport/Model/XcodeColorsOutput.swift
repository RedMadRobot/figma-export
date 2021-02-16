import Foundation

public struct XcodeColorsOutput {
    
    public let assetsColorsURL: URL?
    public let assetsInMainBundle: Bool
    public let assetsInSwiftPackage: Bool
    public let colorSwiftURL: URL?
    public let swiftuiColorSwiftURL: URL?
    
    public init(
        assetsColorsURL: URL?,
        assetsInMainBundle: Bool,
        assetsInSwiftPackage: Bool,
        colorSwiftURL: URL? = nil,
        swiftuiColorSwiftURL: URL? = nil) {
        self.assetsColorsURL = assetsColorsURL
        self.assetsInMainBundle = assetsInMainBundle
        self.assetsInSwiftPackage = assetsInSwiftPackage
        self.colorSwiftURL = colorSwiftURL
        self.swiftuiColorSwiftURL = swiftuiColorSwiftURL
    }
}
