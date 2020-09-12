import Foundation
import FigmaExportCore

final public class XcodeIconsExporter {

    private let output: XcodeImagesOutput
    
    public init(output: XcodeImagesOutput) {
        self.output = output
    }
    
    public func export(assets: [Image]) -> [FileContents] {
        var files: [FileContents] = []
        
        // Assets.xcassets/Icons/Contents.json
        let contentsJson = XcodeEmptyContents()
        files.append(FileContents(
            destination: Destination(directory: output.assetsFolderURL, file: contentsJson.fileURL),
            data: contentsJson.data
        ))
        
        assets.forEach { image in
            // Create directory for imageset
            let dirURL = output.assetsFolderURL.appendingPathComponent("\(image.name).imageset")

            // Write PDF to imageset directory
            let imageURL = URL(string: "\(image.name).\(image.format)")!
            
            files.append(FileContents(
                destination: Destination(directory: dirURL, file: imageURL),
                sourceURL: image.url
            ))
            
            let preservesVector = output.preservesVectorRepresentation?.first(where: { $0 == image.name }) != nil
            
            // Assets.xcassets/Icons/***.imageset/Contents.json
            let contents = XcodeAssetContents(
                icons: [XcodeAssetContents.ImageData(filename: "\(image.name).\(image.format)")],
                preservesVectorRepresentation: preservesVector
            )
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try! encoder.encode(contents)
            let fileURL = URL(string: "Contents.json")!
            files.append(FileContents(
                destination: Destination(directory: dirURL, file: fileURL),
                data: data
            ))
        }
        
        
        // SwiftUI extension Image {
        if let url = output.imageExtensionSwiftURL {
            let data = makeSwiftUIExtension(assets: assets).data(using: .utf8)!
            
            let fileURL = URL(string: url.lastPathComponent)!
            let directoryURL = url.deletingLastPathComponent()
            
            files.append(FileContents(
                destination: Destination(directory: directoryURL, file: fileURL),
                data: data
            ))
        }
        
        return files
    }
    
    private func makeSwiftUIExtension(assets: [Image]) -> String {
        let images = assets.map { asset -> String in
            return "    static var \(asset.name): Image { return Image(#function) }"
        }
        
        return """
        \(header)

        import SwiftUI

        extension Image {
        \(images.joined(separator: "\n"))
        }

        """
    }

}
