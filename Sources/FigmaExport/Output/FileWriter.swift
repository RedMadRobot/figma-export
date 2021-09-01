import Foundation
import FigmaExportCore

final class FileWriter {
    
    private let fileManager: FileManager
    
    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }
    
    func write(files: [FileContents]) throws {
        try files.forEach { file in
            let directoryURL = URL(fileURLWithPath: file.destination.directory.path)
            try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true, attributes: nil)
            
            let fileURL = URL(fileURLWithPath: file.destination.url.path)
            if let data = file.data {
                try data.write(to: fileURL, options: .atomicWrite)
            } else if let localFileURL = file.dataFile {
                _ = try fileManager.replaceItemAt(fileURL, withItemAt: localFileURL)
            } else {
                fatalError("FileContents.data is nil. Use FileDownloader to download contents of the file.")
            }
        }
    }
}
