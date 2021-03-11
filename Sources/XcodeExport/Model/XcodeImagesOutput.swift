import Foundation
import FigmaExportCore

public struct XcodeImagesOutput {
    
    let assetsFolderURL: URL
    let assetsInMainBundle: Bool
    let preservesVectorRepresentation: Bool
    let preservesVectorRepresentationIcons: [String]?
    let renderIntent: RenderIntent?
    let renderAsOriginalIcons: [String]?
    let renderAsTemplateIcons: [String]?
    
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
        preservesVectorRepresentation: Bool = false,
        preservesVectorRepresentationIcons: [String]? = nil,
        renderIntent: RenderIntent? = nil,
        renderAsOriginalIcons: [String]? = nil,
        renderAsTemplateIcons: [String]? = nil,
        uiKitImageExtensionURL: URL? = nil,
        swiftUIImageExtensionURL: URL? = nil) {
        
        self.assetsFolderURL = assetsFolderURL
        self.assetsInMainBundle = assetsInMainBundle
        self.preservesVectorRepresentation = preservesVectorRepresentation
        self.preservesVectorRepresentationIcons = preservesVectorRepresentationIcons
        self.renderIntent = renderIntent
        self.renderAsOriginalIcons = renderAsOriginalIcons
        self.renderAsTemplateIcons = renderAsTemplateIcons
        self.uiKitImageExtensionURL = uiKitImageExtensionURL
        self.swiftUIImageExtensionURL = swiftUIImageExtensionURL
    }
}
