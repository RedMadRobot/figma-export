import Foundation
import FigmaExportCore

/// PNG to WebP converter
final class WebpConverter {
    
    enum Encoding {
        case lossy(quality: Int)
        case lossless
    }
    
    private let encoding: Encoding
    
    init(encoding: Encoding) {
        self.encoding = encoding
    }
    
    /// Converts PNG files to WebP
    func convert(file url: URL) throws {
        let outputURL = url.deletingPathExtension().appendingPathExtension("webp")
        
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/local/bin/cwebp")
        if case Encoding.lossless = encoding {
            task.arguments = ["-lossless", url.path, "-o", outputURL.path, "-short"]
        } else if case Encoding.lossy(let quality) = encoding {
            task.arguments = ["-q", String(quality), url.path, "-o", outputURL.path, "-short"]
        }
        try task.run()
        task.waitUntilExit()
    }
}
