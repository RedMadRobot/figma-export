import Foundation
import FigmaExportCore

public struct XcodeImagesOutput {
    
    let assetsFolderURL: URL
    let assetsInMainBundle: Bool
    let assetsInSwiftPackage: Bool
    let preservesVectorRepresentation: [String]?
    let renderMode: XcodeRenderMode?
    
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
        preservesVectorRepresentation: [String]? = nil,
        uiKitImageExtensionURL: URL? = nil,
        swiftUIImageExtensionURL: URL? = nil,
        renderMode: XcodeRenderMode? = nil) {
        
        self.assetsFolderURL = assetsFolderURL
        self.assetsInMainBundle = assetsInMainBundle
        self.assetsInSwiftPackage = assetsInSwiftPackage ?? false
        self.preservesVectorRepresentation = preservesVectorRepresentation
        self.uiKitImageExtensionURL = uiKitImageExtensionURL
        self.swiftUIImageExtensionURL = swiftUIImageExtensionURL
        self.renderMode = renderMode
    }
}
