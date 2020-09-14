import Foundation
import FigmaExportCore

public struct XcodeImagesOutput {
    
    let assetsFolderURL: URL
    let assetsInMainBundle: Bool
    let preservesVectorRepresentation: [String]?
    
    let uiKitImageExtensionURL: URL?
    let swiftUIImageExtensionURL: URL?

    /// - Parameters:
    ///   - assetsFolderURL: An URL of a folder where to place icons/images
    ///   - preservesVectorRepresentation: A list of image names which should preserve vector data
    ///   - uiKitImageExtensionURL: URL of the swift file where to generate extension for UIImage class
    ///   - swiftUIImageExtensionURL: URL of the swift file where to generate extension for Image struct
    public init(
        assetsFolderURL: URL,
        assetsInMainBundle: Bool,
        preservesVectorRepresentation: [String]? = nil,
        uiKitImageExtensionURL: URL? = nil,
        swiftUIImageExtensionURL: URL? = nil) {
        
        self.assetsFolderURL = assetsFolderURL
        self.assetsInMainBundle = assetsInMainBundle
        self.preservesVectorRepresentation = preservesVectorRepresentation
        self.uiKitImageExtensionURL = uiKitImageExtensionURL
        self.swiftUIImageExtensionURL = swiftUIImageExtensionURL
    }
}
