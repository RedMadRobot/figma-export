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
            
            let fileName: String
            switch platform {
            case .android:
                fileName = "android"
            case .ios:
                fileName = "ios"
            }
            guard let url = Bundle.module.url(forResource: fileName, withExtension: "yaml") else {
                logger.info("Unable to generate config file.")
                return
            }
            
            let destination = FileManager.default.currentDirectoryPath + "/" + "figma-export.yaml"
            try? FileManager.default.removeItem(atPath: destination)
            try FileManager.default.copyItem(atPath: url.path, toPath: destination)
            
            logger.info("Config file generated at:\n\(destination)")
        }
    }
}
