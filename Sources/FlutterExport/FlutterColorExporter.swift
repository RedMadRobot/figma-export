import Foundation
import FigmaExportCore
import Stencil
import PathKit
import Logging

public class FlutterColorExporter: FlutterExporterBase {
    enum Error: Swift.Error, LocalizedError {
        case noColors
        case unspecifiedVariation(String, String)

        var errorDescription: String? {
            switch self {
            case .noColors:
                "There are no colors. Try to check if there are Figma API or parsing errors, and if figma-export.yaml is correct."
            case let .unspecifiedVariation(variation, color):
                "Variation \"\(variation)\" is not specified for the color \"\(color)\". Skipping \"\(color)\"."
            }
        }
    }

    private let output: FlutterColorsOutput
    private let logger: Logger

    public init(output: FlutterColorsOutput, logger: Logger) {
        self.output = output
        self.logger = logger
    }

    public func export(colorPairs: [AssetPair<Color>]) throws -> [FileContents] {
        var fileContents: [FileContents] = []
        fileContents.append(
            try makeFileContents(for: makeContents(colorPairs), url: output.outputURL)
        )
        return fileContents
    }

    private func makeContents(_ colorPairs: [AssetPair<Color>]) throws -> String {
        guard let firstColor = colorPairs.first else {
            throw Error.noColors
        }

        var variations: [Variation] = [.light]
        if firstColor.dark != nil {
            variations.append(.dark)
        }
        if firstColor.lightHC != nil {
            variations.append(.lightHighContrast)
        }
        if firstColor.darkHC != nil {
            variations.append(.darkHighContrast)
        }

        func colorForVariationFromPair(colorPair: AssetPair<Color>, variation: Variation) -> Color? {
            switch variation {
            case .light:
                colorPair.light
            case .dark:
                colorPair.dark
            case .lightHighContrast:
                colorPair.lightHC
            case .darkHighContrast:
                colorPair.darkHC
            }
        }

        var errors: [Swift.Error] = []
        var colors: [Any] = []

        for colorPair in colorPairs {
            do {
                try validateName(colorPair.light.name)
            } catch {
                logger.warning("\(error.localizedDescription)")
                continue
            }
            var colorVariations: [String: ColorWithVariations.Variation] = [:]
            var simpleColors: [SimpleColor] = []
            for variation in variations {
                if let color = colorForVariationFromPair(colorPair: colorPair, variation: variation) {
                    if output.generateVariationsAsProperties {
                        colorVariations[variation.rawValue] = ColorWithVariations.Variation(
                            a: Int(color.alpha * 255),
                            r: Int(color.red * 255),
                            g: Int(color.green * 255),
                            b: Int(color.blue * 255)
                        )
                    } else {
                        simpleColors.append(
                            SimpleColor(
                                name: colorPair.light.name + variation.capitalized,
                                a: Int(color.alpha * 255),
                                r: Int(color.red * 255),
                                g: Int(color.green * 255),
                                b: Int(color.blue * 255)
                            )
                        )
                    }
                } else if output.generateVariationsAsProperties {
                    errors.append(Error.unspecifiedVariation(variation.rawValue, colorPair.light.name))
                }
            }
            if output.generateVariationsAsProperties && colorVariations.count == variations.count {
                colors.append(
                    ColorWithVariations(
                        name: colorPair.light.name,
                        variations: colorVariations
                    )
                )
            } else {
                colors += simpleColors
            }
        }

        if output.generateVariationsAsProperties && !errors.isEmpty {
            throw ErrorGroup(all: errors)
        }

        let context: [String: Any] = [
            "colors": colors,
            "variations": variations.map { $0.rawValue },
            "colorsClassName": output.colorsClassName,
            "generateVariationsAsProperties": output.generateVariationsAsProperties
        ]

        let env = makeEnvironment(templatesPath: output.templatesURL)
        return try env.renderTemplate(name: "colors.dart.stencil", context: context)
    }
}

private enum Variation: String {
    case light, dark, lightHighContrast, darkHighContrast

    var capitalized: String {
        switch self {
        case .light:
            "Light"
        case .dark:
            "Dark"
        case .lightHighContrast:
            "LightHighContrast"
        case .darkHighContrast:
            "DarkHighContrast"
        }
    }
}
