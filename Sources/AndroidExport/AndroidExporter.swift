import Stencil
import PathKit
import Foundation
import FigmaExportCore

public class AndroidExporter {
    
    private let templatesPath: URL?
    
    init(templatesPath: URL?) {
        self.templatesPath = templatesPath
    }
    
    func makeEnvironment() -> Environment {
        let loader: FileSystemLoader
        if let templateURL = templatesPath {
            loader = FileSystemLoader(paths: [Path(templateURL.path)])
        } else {
            loader = FileSystemLoader(paths: [
                Path(Bundle.module.resourcePath! + "/Resources"),
                Path(Bundle.module.resourcePath!)
            ])
        }
        return Environment(loader: loader)
    }
    
    func makeFileContents(for string: String, directory: URL, file: URL) throws -> FileContents {
        FileContents(
            destination: Destination(directory: directory, file: file),
            data: string.data(using: .utf8)!
        )
    }
}
