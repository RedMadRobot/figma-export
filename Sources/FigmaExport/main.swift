import ArgumentParser
import Foundation

enum FigmaExportError: LocalizedError {
    
    case invalidFileName(String)
    case stylesNotFound
    case componentsNotFound
    case accessTokenNotFound
    case colorsAssetsFolderNotSpecified
    
    var errorDescription: String? {
        switch self {
        case .invalidFileName(let name):
            return "File name is invalid: \(name)"
        case .stylesNotFound:
            return "Color/Text styles not found in the Figma file. Have you published Styles to the Library?"
        case .componentsNotFound:
            return "Components not found in the Figma file. Have you published Components to the Library?"
        case .accessTokenNotFound:
            return "Environment varibale FIGMA_PERSONAL_TOKEN not specified."
        case .colorsAssetsFolderNotSpecified:
            return "Option ios.colors.assetsFolder not specified in configuration file."
        }
    }
}

struct FigmaExportCommand: ParsableCommand {
    
    static let version = "0.18.7"
    
    static let svgFileConverter = VectorDrawableConverter()
    static let fileWritter = FileWritter()
    static let fileDownloader = FileDownloader()
    
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
