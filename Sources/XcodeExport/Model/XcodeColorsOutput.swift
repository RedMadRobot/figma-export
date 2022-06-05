import Foundation
import FigmaExportCore

public struct XcodeColorsOutput {
    
    public let assetsColorsURL: URL?
    public let assetsInMainBundle: Bool
    public let assetsInSwiftPackage: Bool
    public let resourceBundleNames: [String]?
    public let addObjcAttribute: Bool
    public let colorSwiftURL: URL?
    public let swiftuiColorSwiftURL: URL?
    public let groupUsingNamespace: Bool
    public let templatesPath: URL?
    
    public init(
        assetsColorsURL: URL?,
        assetsInMainBundle: Bool,
        assetsInSwiftPackage: Bool? = false,
        resourceBundleNames: [String]? = nil,
        addObjcAttribute: Bool? = false,
        colorSwiftURL: URL? = nil,
        swiftuiColorSwiftURL: URL? = nil,
        groupUsingNamespace: Bool? = nil,
        templatesPath: URL? = nil
    ) {
        self.assetsColorsURL = assetsColorsURL
        self.assetsInMainBundle = assetsInMainBundle
        self.assetsInSwiftPackage = assetsInSwiftPackage ?? false
        self.resourceBundleNames = resourceBundleNames
        self.addObjcAttribute = addObjcAttribute ?? false
        self.colorSwiftURL = colorSwiftURL
        self.swiftuiColorSwiftURL = swiftuiColorSwiftURL
        self.groupUsingNamespace = groupUsingNamespace ?? false
        self.templatesPath = templatesPath
    }
}
