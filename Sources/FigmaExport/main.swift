//
//  main.swift
//  Figma-Export-iOS
//
//  Created by Ivan Mikhailovskii on 16.10.2020.
//

import ArgumentParser
import Foundation

enum FigmaExportError: LocalizedError {
    
    case stylesNotFound
    case componentsNotFound
    case accessTokenNotFound
    case colorsAssetsFolderNotSpecified
    
    var errorDescription: String? {
        switch self {
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
    
    static let svgFileConverter = VectorDrawableConverter()
    static let fileWritter = FileWritter()
    static let fileDownloader = FileDownloader()
    
    static var configuration = CommandConfiguration(
        commandName: "figma-export icons",
        abstract: "Exports resources from Figma",
        discussion: "Exports resources (colors, icons, images, typography) from Figma to Xcode / Android Studio project",
        subcommands: [
            ExportColors.self,
            ExportIcons.self,
            ExportImages.self,
            ExportTypography.self,
            ExportDimensions.self,
            GenerateConfigFile.self
        ],
        defaultSubcommand: ExportTypography.self
    )
}

FigmaExportCommand.main()
