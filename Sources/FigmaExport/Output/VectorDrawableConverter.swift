import FigmaExportCore
import Foundation
import Logging

/// SVG to XML converter
final class VectorDrawableConverter {
    private static let notSupportedWarning = "is not supported"
    private let logger = Logger(label: "com.redmadrobot.figma-export.vector-drawable-converter")

    /// Converts SVG files to XML
    /// In case unsupported XML-Tags are reported, the converting command will be executed for each file for better logging.
    /// - Parameter inputDirectoryUrl: Url to directory with SVG files
    func convert(inputDirectoryUrl: URL) throws {
        let errorPipe = Pipe()
        let outputPipe = Pipe()
        let directoryTaskArguments = ["-c", "-in", inputDirectoryUrl.path]

        try runVdTool(with: directoryTaskArguments, errorPipe: errorPipe, outputPipe: outputPipe)

        let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
        let error = String(decoding: errorData, as: UTF8.self)

        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let outputString = String(decoding: outputData, as: UTF8.self)
        // Only log last line out standard output
        outputString.lastLine.flatMap { logger.info("\($0)") }
        
        if error.contains("Unable to locate a Java Runtime") {
            throw FigmaExportError.custom(errorString: error)
        }
        
        if error.contains(Self.notSupportedWarning) {
            logger.warning("vd-tool reported unsupported xml tags. Executing vd-tool for each file...")
            let enumerator = FileManager.default.enumerator(at: inputDirectoryUrl, includingPropertiesForKeys: nil)
            while let file = enumerator?.nextObject() as? URL {
                guard file.pathExtension == "svg" else { continue }
                let fileErrorPipe = Pipe()
                let fileTaskArguments = ["-c", "-in", file.path, "-out", inputDirectoryUrl.path]
                logger.info("Converting file: \(file.path)")
                try runVdTool(with: fileTaskArguments, errorPipe: fileErrorPipe)

                let fileErrorData = fileErrorPipe.fileHandleForReading.readDataToEndOfFile()
                let fileError = String(decoding: fileErrorData, as: UTF8.self)

                if fileError.contains(Self.notSupportedWarning) {
                    logger.warning("Error in file: \(file.path)\n\(fileError)")
                }
            }
        }
    }

    private func runVdTool(with arguments: [String], errorPipe: Pipe?, outputPipe: Pipe? = nil) throws {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/local/bin/vd-tool")
        task.arguments = arguments

        task.standardOutput = outputPipe
        task.standardError = errorPipe

        do {
            try task.run()
        } catch {
            task.executableURL = URL(fileURLWithPath: "./vd-tool/bin/vd-tool")
            try task.run()
        }

        task.waitUntilExit()
    }
}

private extension String {
    var lastLine: String? {
        split { $0 == "\n" }.compactMap(String.init).last
    }
}
