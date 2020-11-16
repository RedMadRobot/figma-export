import Foundation
import FigmaExportCore

final public class XcodeImagesExporter: XcodeImagesExporterBase {

    public func export(assets: [AssetPair<ImagePack>], append: Bool) throws -> [FileContents] {
        // Generate assets
        let assetsFolderURL = output.assetsFolderURL

        // Generate metadata (Assets.xcassets/Illustrations/Contents.json)
        let contentsFile = XcodeEmptyContents().makeFileContents(to: assetsFolderURL)

        let imageAssetsFiles = try assets.flatMap { pair -> [FileContents] in
            try pair.makeFileContents(to: assetsFolderURL, preservesVector: nil)
        }

        // Generate extensions
        let imageNames = assets.map { $0.light.name }
        let extensionFiles = try generateExtensions(names: imageNames, append: append)

        return [contentsFile] + imageAssetsFiles + extensionFiles
    }

}
