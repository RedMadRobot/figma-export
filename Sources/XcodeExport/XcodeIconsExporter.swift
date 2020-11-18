import Foundation
import FigmaExportCore

final public class XcodeIconsExporter: XcodeImagesExporterBase {

    public func export(icons: [ImagePack], append: Bool) throws -> [FileContents] {
        // Generate metadata (Assets.xcassets/Icons/Contents.json)
        let contentsFile = XcodeEmptyContents().makeFileContents(to: output.assetsFolderURL)

        // Generate assets
        let assetsFolderURL = output.assetsFolderURL
        let preservesVectorRepresentation = output.preservesVectorRepresentation

        let imageAssetsFiles = try icons.flatMap { imagePack -> [FileContents] in
            let preservesVector = preservesVectorRepresentation?.first(where: { $0 == imagePack.name }) != nil
            return try imagePack.makeFileContents(to: assetsFolderURL, preservesVector: preservesVector)
        }

        // Generate extensions
        let imageNames = icons.map { $0.name }
        let extensionFiles = try generateExtensions(names: imageNames, append: append)

        return [contentsFile] + imageAssetsFiles + extensionFiles
    }
    
}
