import Foundation
import FigmaExportCore
import Stencil

final public class XcodeDimensionsExporter {

    public init() {}

    public func export(
        _ components: [UIComponent],
        folderURL: URL,
        fileName: String?
    ) throws -> FileContents {
        let styles = components
            .sorted(by: { $0.name < $1.name })
            .map { component in
                "\"\(component.cornerRadiusDimensionName)\" : \(component.cornerRadius)"
            }
        let jsonData = """
        {
          \(styles.joined(separator: ",\n  "))
        }
        """
        return try XcodeDimensionsExporter.makeFileContents(
            data: jsonData as String,
            directoryURL: folderURL,
            fileName: fileName ?? "dimensions.json"
        )
    }
    
    static func makeFileContents(data: String, directoryURL: URL, fileName: String) throws -> FileContents {
        let data = data.data(using: .utf8)!
        let fileURL = URL(string: fileName)!
        let destination = Destination(directory: directoryURL, file: fileURL)
        return FileContents(destination: destination, data: data)
    }
}
