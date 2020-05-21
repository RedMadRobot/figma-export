import Foundation
import FigmaExportCore

final class FileConverter {
    
    func convert(inputDirectoryPath: String) throws {
        let task = Process()
        #if DEBUG
        task.executableURL = URL(fileURLWithPath: "/Users/d.subbotin/Documents/projects/figma-export/Release/vd-tool/bin/vd-tool")
        #else
        task.executableURL = URL(fileURLWithPath: "./vd-tool/bin/vd-tool")
        #endif
        task.arguments = ["-c", "-in", inputDirectoryPath]
        try task.run()
        task.waitUntilExit()
    }
}
