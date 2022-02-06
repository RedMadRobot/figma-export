import Foundation
import FigmaExportCore

final public class AndroidTypographyExporter: AndroidExporter {

    private let output: AndroidOutput

    public init(output: AndroidOutput) {
        self.output = output
        super.init(templatesPath: output.templatesPath)
    }

    public func exportFonts(textStyles: [TextStyle]) throws -> [FileContents] {
        var files: [FileContents] = []
        
        // typography.xml
        files.append(try makeTypographyXMLFileContents(textStyles: textStyles))
        
        // Typography.kt
        if
            let composeOutputDirectory = output.composeOutputDirectory,
            let packageName = output.packageName,
            let xmlResourcePackage = output.xmlResourcePackage {
            
            files.append(
                try makeTypographyComposeFileContents(
                    textStyles: textStyles,
                    outputDirectory: composeOutputDirectory,
                    package: packageName,
                    xmlResourcePackage: xmlResourcePackage
                )
            )
        }
        
        return files
    }

    private func makeTypographyXMLFileContents(textStyles: [TextStyle]) throws -> FileContents {
        let fonts: [[String: Any]] = textStyles.map { textStyle in
            [
                "name": textStyle.name,
                "fontFamily": androidFontResource(from: textStyle.fontName),
                "textSize": textStyle.fontSize,
                "letterSpacing": androidLetterSpacing(
                    letterSpacing: textStyle.letterSpacing,
                    fontSize: textStyle.fontSize
                )
            ]
        }
        let context: [String: Any] = [
            "textStyles": fonts
        ]
        let env = makeEnvironment(trimBehavior: .smart)
        let contents = try env.renderTemplate(name: "typography.xml.stencil", context: context)
        
        let directoryURL = output.xmlOutputDirectory.appendingPathComponent("values")
        let fileURL = URL(string: "typography.xml")!
        return try makeFileContents(for: contents, directory: directoryURL, file: fileURL)
    }
    
    private func makeTypographyComposeFileContents(
        textStyles: [TextStyle],
        outputDirectory: URL,
        package: String,
        xmlResourcePackage: String
    ) throws -> FileContents {
        let fonts: [[String: Any]] = textStyles.map { textStyle in
            var dict: [String: Any] = [
                "name": textStyle.name,
                "fontFamily": androidFontName(from: textStyle.fontName),
                "fontSize": textStyle.fontSize,
                "letterSpacing": textStyle.letterSpacing
            ]
            if let lineHeight = textStyle.lineHeight {
                dict["lineHeight"] = lineHeight
            }
            return dict
        }
        let context: [String: Any] = [
            "textStyles": fonts,
            "package": package,
            "xmlResourcePackage": xmlResourcePackage
        ]
        let env = makeEnvironment(trimBehavior: .none)
        let contents = try env.renderTemplate(name: "Typography.kt.stencil", context: context)
        
        let fileURL = URL(string: "Typography.kt")!
        return try makeFileContents(for: contents, directory: outputDirectory, file: fileURL)
    }

    private func androidFontResource(from postscriptName: String) -> String {
        "@font/\(androidFontName(from: postscriptName))"
    }
    
    private func androidFontName(from postscriptName: String) -> String {
        postscriptName.lowercased().replacingOccurrences(of: "-", with: "_")
    }

    private func androidLetterSpacing(letterSpacing: Double, fontSize: Double) -> String {
        String(format: "%.2f", letterSpacing / fontSize)
    }
}
