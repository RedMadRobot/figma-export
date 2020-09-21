import Foundation
import FigmaExportCore

/// SVG to XML converter
final class VectorDrawableConverter {
    
    /// Converts SVG files to XML
    /// - Parameter inputDirectoryPath: Path to directory with SVG files
    func convert(inputDirectoryPath: String) throws {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/local/bin/vd-tool")
        task.arguments = ["-c", "-in", inputDirectoryPath]
        do {
            try task.run()
        } catch {
            task.executableURL = URL(fileURLWithPath: "./vd-tool/bin/vd-tool")
            try task.run()
        }
        task.waitUntilExit()
    }
}
