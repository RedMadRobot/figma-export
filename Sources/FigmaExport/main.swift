import ArgumentParser
import Foundation
import Logging

enum FigmaExportError: LocalizedError {
    
    case invalidFileName(String)
    case stylesNotFound
    case componentsNotFound
    case accessTokenNotFound
    case colorsAssetsFolderNotSpecified
    case custom(errorString: String)
    
    var errorDescription: String? {
        switch self {
        case .invalidFileName(let name):
            return "File name is invalid: \(name)"
        case .stylesNotFound:
            return "Color/Text styles not found in the Figma file. Have you published Styles to the Library?"
        case .componentsNotFound:
            return "Components not found in the Figma file. Have you published Components to the Library?"
        case .accessTokenNotFound:
            return "Environment variable FIGMA_PERSONAL_TOKEN not specified."
        case .colorsAssetsFolderNotSpecified:
            return "Option ios.colors.assetsFolder not specified in configuration file."
        case .custom(let errorString):
            return errorString
        }
    }
}

struct FigmaExportCommand: ParsableCommand {
    
    static let version = "0.34.0"
    
    static let svgFileConverter = VectorDrawableConverter()
    static let fileWriter = FileWriter()
    static let fileDownloader = FileDownloader()
    static let logger = Logger(label: "com.redmadrobot.figma-export")
    
    static var configuration = CommandConfiguration(
        commandName: "figma-export",
        abstract: "Exports resources from Figma",
        discussion: "Exports resources (colors, icons, images) from Figma to Xcode / Android Studio project",
        version: version,
        subcommands: [
            ExportColors.self,
            ExportIcons.self,
            ExportImages.self,
            ExportTypography.self,
            GenerateConfigFile.self
        ],
        defaultSubcommand: ExportColors.self
    )
    
}

FigmaExportCommand.main()
