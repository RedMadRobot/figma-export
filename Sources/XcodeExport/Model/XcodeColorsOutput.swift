import Foundation

public struct XcodeColorsOutput {
    
    public let assetsColorsURL: URL?
    public let colorSwiftURL: URL?
    public let swiftuiColorSwiftURL: URL?
    
    public init(assetsColorsURL: URL?, colorSwiftURL: URL? = nil, swiftuiColorSwiftURL: URL? = nil) {
        self.assetsColorsURL = assetsColorsURL
        self.colorSwiftURL = colorSwiftURL
        self.swiftuiColorSwiftURL = swiftuiColorSwiftURL
    }
}
