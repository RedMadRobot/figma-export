import ArgumentParser
import FigmaExportCore
import Foundation
import Logging

extension Platform: ExpressibleByArgument {}

extension FigmaExportCommand {
    
    struct GenerateConfigFile: ParsableCommand {
        
        static let configuration = CommandConfiguration(
            commandName: "init",
            abstract: "Generates config file",
            discussion: "Generates figma-export.yaml config file in the current directory")
        
        @Option(name: .shortAndLong, help: "Platform: ios or android.")
        var platform: Platform
        
        func run() throws {
            let logger = Logger(label: "com.redmadrobot.figma-export")
            
            let fileContents: String
            switch platform {
            case .android:
                fileContents = androidConfigFileContents
            case .ios:
                fileContents = iosConfigFileContents
            }
            let fileData = fileContents.data(using: .utf8)
            
            let destination = FileManager.default.currentDirectoryPath + "/" + "figma-export.yaml"
            try? FileManager.default.removeItem(atPath: destination)
            let success = FileManager.default.createFile(atPath: destination, contents: fileData, attributes: nil)
            if success {
                logger.info("Config file generated at:\n\(destination)")
            } else {
                logger.error("Unable to generate config file at:\n\(destination)")
            }
        }
    }
}
