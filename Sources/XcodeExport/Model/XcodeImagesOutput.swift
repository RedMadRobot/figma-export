import Foundation
import FigmaExportCore

public struct XcodeImagesOutput {
    
    let assetsFolderURL: URL
    let assetsInMainBundle: Bool
    let assetsInSwiftPackage: Bool
    let resourceBundleNames: [String]?
    let addObjcAttribute: Bool
    let preservesVectorRepresentation: [String]?
    let templatesPath: URL?
    
    let uiKitImageExtensionURL: URL?
    let swiftUIImageExtensionURL: URL?

    /// - Parameters:
    ///   - assetsFolderURL: An URL of a folder where to place icons/images
    ///   - preservesVectorRepresentation: A list of image names which should preserve vector data
    ///   - uiKitImageExtensionURL: URL of the swift file where to generate extension for UIImage class
    ///   - swiftUIImageExtensionURL: URL of the swift file where to generate extension for Image struct
    ///   - renderMode: Xcode Asset Catalog render mode
    public init(
        assetsFolderURL: URL,
        assetsInMainBundle: Bool,
        assetsInSwiftPackage: Bool? = false,
        resourceBundleNames: [String]? = nil,
        addObjcAttribute: Bool? = false,
        preservesVectorRepresentation: [String]? = nil,
        uiKitImageExtensionURL: URL? = nil,
        swiftUIImageExtensionURL: URL? = nil,
        templatesPath: URL? = nil
    ) {
        self.assetsFolderURL = assetsFolderURL
        self.assetsInMainBundle = assetsInMainBundle
        self.assetsInSwiftPackage = assetsInSwiftPackage ?? false
        self.resourceBundleNames = resourceBundleNames
        self.addObjcAttribute = addObjcAttribute ?? false
        self.preservesVectorRepresentation = preservesVectorRepresentation
        self.uiKitImageExtensionURL = uiKitImageExtensionURL
        self.swiftUIImageExtensionURL = swiftUIImageExtensionURL
        self.templatesPath = templatesPath
    }
}
