import Foundation
import FigmaExportCore

public struct XcodeImagesOutput {
    
    let assetsFolderURL: URL
    let preservesVectorRepresentation: [String]?

    ///   - assetsFolderURL: An URL of a folder where to place icons/images
    ///   - preservesVectorRepresentation: Preserve vector data?
    public init(assetsFolderURL: URL, preservesVectorRepresentation: [String]? = nil) {
        self.assetsFolderURL = assetsFolderURL
        self.preservesVectorRepresentation = preservesVectorRepresentation
    }
}
