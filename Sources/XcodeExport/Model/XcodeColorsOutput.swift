import Foundation
import FigmaExportCore

public struct XcodeColorsOutput {
    
    public let assetsColorsURL: URL?
    public let assetsInMainBundle: Bool
    public let assetsInSwiftPackage: Bool
    public let addObjcAttribute: Bool
    public let colorSwiftURL: URL?
    public let swiftuiColorSwiftURL: URL?
    public let groupUsingNamespace: Bool
    
    public init(
        assetsColorsURL: URL?,
        assetsInMainBundle: Bool,
        assetsInSwiftPackage: Bool? = false,
        addObjcAttribute: Bool? = false,
        colorSwiftURL: URL? = nil,
        swiftuiColorSwiftURL: URL? = nil,
        groupUsingNamespace: Bool? = nil) {
        self.assetsColorsURL = assetsColorsURL
        self.assetsInMainBundle = assetsInMainBundle
        self.assetsInSwiftPackage = assetsInSwiftPackage ?? false
        self.addObjcAttribute = addObjcAttribute ?? false
        self.colorSwiftURL = colorSwiftURL
        self.swiftuiColorSwiftURL = swiftuiColorSwiftURL
        self.groupUsingNamespace = groupUsingNamespace ?? false
    }
}
