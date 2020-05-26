import Foundation

public struct XcodeColorsOutput {
    
    public let assetsColorsURL: URL?
    public let colorSwiftURL: URL
    
    public init(assetsColorsURL: URL?, colorSwiftURL: URL) {
        self.assetsColorsURL = assetsColorsURL
        self.colorSwiftURL = colorSwiftURL
    }
}
