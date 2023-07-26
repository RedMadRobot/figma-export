import Foundation
import FigmaExportCore
import Stencil
import PathKit

final public class AndroidColorExporter: AndroidExporter {

    private let output: AndroidOutput
    private let xmlOutputFileName: String

    public init(output: AndroidOutput, xmlOutputFileName: String?) {
        self.output = output
        self.xmlOutputFileName = xmlOutputFileName ?? "colors.xml"
        super.init(templatesPath: output.templatesPath)
    }
    
    public func export(colorPairs: [AssetPair<Color>]) throws -> [FileContents] {

        // values/colors.xml
        let lightFile = try makeColorsFileContents(colorPairs: colorPairs, dark: false)
        var result = [lightFile]

        // values-night/colors.xml
        if colorPairs.contains(where: { $0.dark != nil }) {
            let darkFile = try makeColorsFileContents(colorPairs: colorPairs, dark: true)
            result.append(darkFile)
        }

        // Colors.kt
        if let packageName = output.packageName,
           let outputDirectory = output.composeOutputDirectory,
           let xmlResourcePackage = output.xmlResourcePackage {

            let composeFile = try makeComposeColorsFileContents(
                colorPairs: colorPairs,
                package: packageName,
                xmlResourcePackage: xmlResourcePackage,
                outputDirectory: outputDirectory
            )
            result.append(composeFile)
        }
        
        return result
    }
    
    private func makeColorsFileContents(colorPairs: [AssetPair<Color>], dark: Bool) throws -> FileContents {
        let contents = try makeColorsContents(colorPairs, dark: dark)
        
        let directoryURL = output.xmlOutputDirectory.appendingPathComponent(dark ? "values-night" : "values")
        let fileURL = URL(string: xmlOutputFileName)!
        
        return try makeFileContents(for: contents, directory: directoryURL, file: fileURL)
    }
    
    private func makeColorsContents(_ colorPairs: [AssetPair<Color>], dark: Bool) throws -> String {
        let colors: [[String: String]] = colorPairs.map { colorPair in
            [
                "name": colorPair.light.name,
                "hex": (dark && colorPair.dark != nil) ? colorPair.dark!.hex : colorPair.light.hex
            ]
        }
        let context: [String: Any] = [
            "colors": colors
        ]
        
        let env = makeEnvironment()
        return try env.renderTemplate(name: "colors.xml.stencil", context: context)
    }
    
    private func makeComposeColorsFileContents(
        colorPairs: [AssetPair<Color>],
        package: String,
        xmlResourcePackage: String,
        outputDirectory: URL
    ) throws -> FileContents {
        let colors: [[String: String]] = colorPairs.map {
            [
                "functionName": $0.light.name.lowerCamelCased(),
                "name": $0.light.name
            ]
        }

        let context: [String: Any] = [
            "package": package,
            "xmlResourcePackage": xmlResourcePackage,
            "colors": colors
        ]

        let env = makeEnvironment()
        let string = try env.renderTemplate(name: "Colors.kt.stencil", context: context)
        
        let fileURL = URL(string: "Colors.kt")!
        return try makeFileContents(for: string, directory: outputDirectory, file: fileURL)
    }
}

private extension Color {

    func doubleToHex(_ double: Double) -> String {
        String(format: "%02X", arguments: [Int((double * 255).rounded())])
    }

    var hex: String {
        let rr = doubleToHex(red)
        let gg = doubleToHex(green)
        let bb = doubleToHex(blue)
        var result = "#\(rr)\(gg)\(bb)"
        if alpha != 1.0 {
            let aa = doubleToHex(alpha)
            result = "#\(aa)\(rr)\(gg)\(bb)"
        }
        return result
    }
}
