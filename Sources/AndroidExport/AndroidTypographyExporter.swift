import Foundation
import FigmaExportCore
import Stencil

final public class AndroidTypographyExporter {

    private let outputDirectory: URL

    public init(outputDirectory: URL) {
        self.outputDirectory = outputDirectory
    }

    public func exportFonts(textStyles: [TextStyle]) throws -> [FileContents] {
        [makeFontsFile(textStyles: textStyles)]
    }

    private func makeFontsFile(textStyles: [TextStyle]) -> FileContents {
        let contents = prepareFontsDotXMLContents(textStyles)
        let directoryURL = outputDirectory.appendingPathComponent("values")
        let fileURL = URL(string: "typography.xml")!

        return FileContents(
            destination: Destination(directory: directoryURL, file: fileURL),
            data: contents
        )
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

            let fontFamilyItem = XMLElement(name: "item", stringValue: textStyle.fontName)
            fontFamilyItem.addAttribute(XMLNode.attribute(withName: "name", stringValue: "android:fontFamily") as! XMLNode)
            textStyleNode.addChild(fontFamilyItem)

            let fontSizeItem = XMLElement(name: "item", stringValue: "\(textStyle.fontSize)")
            fontSizeItem.addAttribute(XMLNode.attribute(withName: "name", stringValue: "android:fontSize") as! XMLNode)
            textStyleNode.addChild(fontSizeItem)
        }

        return xml.xmlData(options: .nodePrettyPrint)
    }
}
