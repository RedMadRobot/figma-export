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

    public func export(assets: [Image], append: Bool) throws -> [FileContents] {
        var files: [FileContents] = []
        
        // Assets.xcassets/Icons/Contents.json
        let contentsJson = XcodeEmptyContents()
        files.append(FileContents(
            destination: Destination(directory: output.assetsFolderURL, file: contentsJson.fileURL),
            data: contentsJson.data
        ))
        
        try assets.forEach { image in
            // Create directory for imageset
            let dirURL = output.assetsFolderURL.appendingPathComponent("\(image.name).imageset")

            // Write PDF to imageset directory
            let imageURL = URL(string: "\(image.name).\(image.format)")!
            
            files.append(FileContents(
                destination: Destination(directory: dirURL, file: imageURL),
                sourceURL: image.url
            ))
            
            let preservesVector = output.preservesVectorRepresentation?.first(where: { $0 == image.name }) != nil

            let idiom = image.idiom.flatMap({ XcodeAssetIdiom(rawValue: $0) }) ?? .universal
            
            // Assets.xcassets/Icons/***.imageset/Contents.json
            let contents = XcodeAssetContents(
                icons: [XcodeAssetContents.ImageData(idiom: idiom, filename: "\(image.name).\(image.format)")],
                preservesVectorRepresentation: preservesVector
            )
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(contents)
            let fileURL = URL(string: "Contents.json")!
            files.append(FileContents(
                destination: Destination(directory: dirURL, file: fileURL),
                data: data
            ))
        }
        
        let imageNames = assets.map { $0.name }
        
        let extensionFiles = try generateExtensions(names: imageNames, append: append)
        files.append(contentsOf: extensionFiles)
        
        return files
    }
}
