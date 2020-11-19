import FigmaExportCore
import Foundation

/// SVG to XML converter
final class VectorDrawableConverter {
    /// Converts SVG files to XML
    /// - Parameter inputDirectoryUrl: Url to directory with SVG files
    func convert(inputDirectoryUrl: URL) throws {
        let enumerator = FileManager.default.enumerator(at: inputDirectoryUrl, includingPropertiesForKeys: nil)

        while let file = enumerator?.nextObject() as? URL {
            guard file.pathExtension == "svg" else { return }
            let task = Process()
            task.executableURL = URL(fileURLWithPath: "/usr/local/bin/vd-tool")
            task.arguments = ["-c", "-in", file.path, "-out", inputDirectoryUrl.path]

            do {
                try task.run()
            } catch {
                task.executableURL = URL(fileURLWithPath: "./vd-tool/bin/vd-tool")
                try task.run()
            }

            task.waitUntilExit()
        }
    }
}
