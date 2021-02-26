import Foundation
import FigmaExportCore

final public class AndroidColorExporter {

    private let outputDirectory: URL
    private let outputHexFormat: String

    public init(outputDirectory: URL, outputHexFormat: String) {
        self.outputDirectory = outputDirectory
        self.outputHexFormat = outputHexFormat
    }
    
    public func export(colorPairs: [AssetPair<Color>]) -> [FileContents] {
        
        let lightFile = makeColorsFile(colorPairs: colorPairs, dark: false)
        var result = [lightFile]
            
        if colorPairs.first?.dark != nil {
            let darkFile = makeColorsFile(colorPairs: colorPairs, dark: true)
            result.append(darkFile)
        }
        
        return result
    }
    
    private func makeColorsFile(colorPairs: [AssetPair<Color>], dark: Bool) -> FileContents {
        let contents = prepareColorsDotXMLContents(colorPairs, dark: dark)
        
        let directoryURL = outputDirectory.appendingPathComponent(dark ? "values-night" : "values")
        let fileURL = URL(string: "colors.xml")!
        
        return FileContents(
            destination: Destination(directory: directoryURL, file: fileURL),
            data: contents
        )
    }
    
    private func prepareColorsDotXMLContents(_ colorPairs: [AssetPair<Color>], dark: Bool) -> Data {
        let resources = XMLElement(name: "resources")
        let xml = XMLDocument(rootElement: resources)
        xml.version = "1.0"
        xml.characterEncoding = "utf-8"
        
        colorPairs.forEach { colorPair in
            if dark, colorPair.dark == nil { return }
            let name = dark ? colorPair.dark!.name : colorPair.light.name
            let hex = dark ? colorPair.dark!.hex(outputHexFormat: outputHexFormat) : colorPair.light.hex(outputHexFormat: outputHexFormat)
            let colorNode = XMLElement(name: "color", stringValue: hex)
            colorNode.addAttribute(XMLNode.attribute(withName: "name", stringValue: name) as! XMLNode)
            resources.addChild(colorNode)
        }
        
        return xml.xmlData(options: .nodePrettyPrint)
    }
}

private extension Color {
    func doubleToHex(_ double: Double) -> String {
        String(format: "%02X", arguments: [Int((double * 255).rounded())])
    }

    func hex(outputHexFormat: String) -> String {
        let rr = doubleToHex(red)
        let gg = doubleToHex(green)
        let bb = doubleToHex(blue)
        var result = "#\(rr)\(gg)\(bb)"
        if alpha != 1.0 {
            let aa = doubleToHex(alpha)
            switch outputHexFormat {
                case "argb":
                    result = "#\(aa)\(rr)\(gg)\(bb)"
                default:
                    result.append(aa)
            }
        }
        return result
    }
}
