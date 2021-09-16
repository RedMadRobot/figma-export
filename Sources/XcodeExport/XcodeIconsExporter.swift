import Foundation
import FigmaExportCore

final public class XcodeIconsExporter: XcodeImagesExporterBase {

    public func export(icons: [AssetPair<ImagePack>], append: Bool) throws -> [FileContents] {
        // Generate metadata (Assets.xcassets/Icons/Contents.json)
        let contentsFile = XcodeEmptyContents().makeFileContents(to: output.assetsFolderURL)

        // Generate assets
        let assetsFolderURL = output.assetsFolderURL
        let preservesVectorRepresentation = output.preservesVectorRepresentation
        // Filtering at suffixes
        let renderMode = output.renderMode ?? .template
        let defaultSuffix = renderMode == .template ? output.renderModeDefaultSuffix : nil
        let originalSuffix = renderMode == .template ? output.renderModeOriginalSuffix : nil
        let templateSuffix = renderMode != .template ? output.renderModeTemplateSuffix : nil

        let imageAssetsFiles = try icons.flatMap { imagePack -> [FileContents] in
            let preservesVector = preservesVectorRepresentation?.first(where: { $0 == imagePack.light.name }) != nil

            if let defaultSuffix = defaultSuffix, imagePack.light.name.hasSuffix(defaultSuffix) {
                return try imagePack.makeFileContents(to: assetsFolderURL, preservesVector: preservesVector, renderMode: .default)
            } else if let originalSuffix = originalSuffix, imagePack.light.name.hasSuffix(originalSuffix) {
                return try imagePack.makeFileContents(to: assetsFolderURL, preservesVector: preservesVector, renderMode: .original)
            } else if let templateSuffix = templateSuffix, imagePack.light.name.hasSuffix(templateSuffix) {
                return try imagePack.makeFileContents(to: assetsFolderURL, preservesVector: preservesVector, renderMode: .template)
            }

            return try imagePack.makeFileContents(to: assetsFolderURL, preservesVector: preservesVector, renderMode: renderMode)
        }

        // Generate extensions
        let imageNames = icons.map { $0.light.name }
        let extensionFiles = try generateExtensions(names: imageNames, append: append)

        return [contentsFile] + imageAssetsFiles + extensionFiles
    }

}
