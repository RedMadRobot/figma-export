import Foundation

public struct XcodeColorsOutput {
    
    public let assetsColorsURL: URL?
    public let assetsInMainBundle: Bool
    public let colorSwiftURL: URL?
    public let swiftuiColorSwiftURL: URL?
    
    public init(assetsColorsURL: URL?, assetsInMainBundle: Bool, colorSwiftURL: URL? = nil, swiftuiColorSwiftURL: URL? = nil) {
        self.assetsColorsURL = assetsColorsURL
        self.assetsInMainBundle = assetsInMainBundle
        self.colorSwiftURL = colorSwiftURL
        self.swiftuiColorSwiftURL = swiftuiColorSwiftURL
    }
}
