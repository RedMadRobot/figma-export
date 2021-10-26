import Foundation
import FigmaExportCore

final public class AndroidTypographyExporter {

    private let output: AndroidOutput

    public init(output: AndroidOutput) {
        self.output = output
    }

    public func exportFonts(textStyles: [TextStyle]) throws -> [FileContents] {
        var files: [FileContents] = []
        
        // android xml export
        files.append(makeFontsFile(textStyles: textStyles))
        
        // android compose typography object
        if let composeOutputDirectory = output.composeOutputDirectory, let packageName = output.packageName, let xmlResourcePackage = output.xmlResourcePackage {
            files.append(makeComposeFontsFile(textStyles: textStyles, outputDirectory: composeOutputDirectory, package: packageName, xmlResourcePackage: xmlResourcePackage))
        }
        
        return files
    }

    private func makeFontsFile(textStyles: [TextStyle]) -> FileContents {
        let contents = prepareFontsDotXMLContents(textStyles)
        let directoryURL = output.xmlOutputDirectory.appendingPathComponent("values")
        let fileURL = URL(string: "typography.xml")!

        return FileContents(
            destination: Destination(directory: directoryURL, file: fileURL),
            data: contents
        )
    }
    
    private func makeComposeFontsFile(textStyles: [TextStyle], outputDirectory: URL, package: String, xmlResourcePackage: String) -> FileContents {
        let fileURL = URL(string: "Typography.kt")!
        
        let fileLines: [String] = textStyles.map {
            var lineHeightLine = ""
            if let lineHeight = $0.lineHeight {
                lineHeightLine = "\n        lineHeight = \(lineHeight).sp,"
            }
            return """
                val \($0.name) = TextStyle(
                    fontFamily = FontFamily(Font(\(androidFontResourceId(from: $0.fontName)))),
                    fontSize = \($0.fontSize).sp,
                    letterSpacing = \($0.letterSpacing).sp,\(lineHeightLine)
                )
            """
        }
        let contents = """
        package \(package)
        
        import androidx.compose.ui.text.TextStyle
        import androidx.compose.ui.text.font.Font
        import androidx.compose.ui.text.font.FontFamily
        import androidx.compose.ui.unit.sp
        import \(xmlResourcePackage).R

        object Typography {
        
        \(fileLines.joined(separator: "\n"))
        }
        
        """
        let data = contents.data(using: .utf8)!
        
        let destination = Destination(directory: outputDirectory, file: fileURL)
        return FileContents(destination: destination, data: data)
    }

    private func prepareFontsDotXMLContents(_ textStyles: [TextStyle]) -> Data {
        let resources = XMLElement(name: "resources")
        let xml = XMLDocument(rootElement: resources)
        xml.version = "1.0"
        xml.characterEncoding = "utf-8"

        textStyles.forEach { textStyle in
            let textStyleNode = XMLElement(name: "style")
            textStyleNode.addAttribute(XMLNode.attribute(withName: "name", stringValue: textStyle.name) as! XMLNode)
            resources.addChild(textStyleNode)
            
            addStyleItem(name: "android:fontFamily", value: androidFontResource(from: textStyle.fontName), textStyleNode: textStyleNode)
            addStyleItem(name: "android:textSize", value: androidSP(from: textStyle.fontSize), textStyleNode: textStyleNode)
            addStyleItem(name: "android:letterSpacing", value: androidLetterSpacing(letterSpacing: textStyle.letterSpacing, fontSize: textStyle.fontSize), textStyleNode: textStyleNode)
        }

        return xml.xmlData(options: .nodePrettyPrint)
    }
    
    private func addStyleItem(name: String, value: String, textStyleNode: XMLElement) {
        let styleItem = XMLElement(name: "item", stringValue: value)
        styleItem.addAttribute(XMLNode.attribute(withName: "name", stringValue: name) as! XMLNode)
        textStyleNode.addChild(styleItem)
    }
    
    private func androidFontResourceId(from postscriptName: String) -> String {
        "R.font.\(androidFontName(from: postscriptName))"
    }
    
    private func androidFontResource(from postscriptName: String) -> String {
        "@font/\(androidFontName(from: postscriptName))"
    }

    private func androidFontName(from postscriptName: String) -> String {
        postscriptName.lowercased().replacingOccurrences(of: "-", with: "_")
    }

    private func androidSP(from points: Double) -> String {
        "\(points)sp"
    }
    
    private func androidLetterSpacing(letterSpacing: Double, fontSize: Double) -> String {
        String(format: "%.2f", letterSpacing / fontSize)
    }
}
