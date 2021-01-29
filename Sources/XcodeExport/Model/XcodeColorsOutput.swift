import Foundation

public struct XcodeColorsOutput {
    
    public let assetsColorsURL: URL?
    public let assetsInMainBundle: Bool
    public let colorSwiftURL: URL?
    public let swiftuiColorSwiftURL: URL?
    public let modifyXcodeproj: Bool
    
    public init(assetsColorsURL: URL?, assetsInMainBundle: Bool, colorSwiftURL: URL? = nil, swiftuiColorSwiftURL: URL? = nil, modifyXcodeproj: Bool = true) {
        self.assetsColorsURL = assetsColorsURL
        self.assetsInMainBundle = assetsInMainBundle
        self.colorSwiftURL = colorSwiftURL
        self.swiftuiColorSwiftURL = swiftuiColorSwiftURL
        self.modifyXcodeproj = modifyXcodeproj
    }
}
