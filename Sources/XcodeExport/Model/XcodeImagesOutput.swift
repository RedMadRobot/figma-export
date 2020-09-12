import Foundation
import FigmaExportCore

public struct XcodeImagesOutput {
    
    let assetsFolderURL: URL
    let preservesVectorRepresentation: [String]?
    let imageExtensionSwiftURL: URL?

    ///   - assetsFolderURL: An URL of a folder where to place icons/images
    ///   - preservesVectorRepresentation: Preserve vector data?
    ///   - imageExtensionSwiftURL: URL of the swift file where to generate swift code for accessing images from the code
    public init(
        assetsFolderURL: URL,
        preservesVectorRepresentation: [String]? = nil,
        imageExtensionSwiftURL: URL? = nil) {
        
        self.assetsFolderURL = assetsFolderURL
        self.preservesVectorRepresentation = preservesVectorRepresentation
        self.imageExtensionSwiftURL = imageExtensionSwiftURL
    }
}
