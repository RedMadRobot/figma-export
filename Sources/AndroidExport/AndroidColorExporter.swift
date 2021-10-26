import Foundation
import FigmaExportCore

final public class AndroidColorExporter {

    private let output: AndroidOutput

    public init(output: AndroidOutput) {
        self.output = output
    }
    
    public func export(colorPairs: [AssetPair<Color>]) -> [FileContents] {
        
        let lightFile = makeColorsFile(colorPairs: colorPairs, dark: false)
        var result = [lightFile]
            
        if colorPairs.contains(where: { $0.dark != nil }) {
            let darkFile = makeColorsFile(colorPairs: colorPairs, dark: true)
            result.append(darkFile)
        }
        
        if let packageName = output.packageName, let outputDirectory = output.composeOutputDirectory, let xmlResourcePackage = output.xmlResourcePackage {
            let composeFile = makeComposeColorsFile(colorPairs: colorPairs, outputDirectory: outputDirectory, package: packageName, xmlResourcePackage: xmlResourcePackage)
            result.append(composeFile)
        }
        
        return result
    }
    
    private func makeColorsFile(colorPairs: [AssetPair<Color>], dark: Bool) -> FileContents {
        let contents = prepareColorsDotXMLContents(colorPairs, dark: dark)
        
        let directoryURL = output.xmlOutputDirectory.appendingPathComponent(dark ? "values-night" : "values")
        let fileURL = URL(string: "colors.xml")!
        
        return FileContents(
            destination: Destination(directory: directoryURL, file: fileURL),
            data: contents
        )
    }
    
    private func makeComposeColorsFile(colorPairs: [AssetPair<Color>], outputDirectory: URL, package: String, xmlResourcePackage: String) -> FileContents {
        let fileURL = URL(string: "Colors.kt")!
        
        let fileLines: [String] = colorPairs.map {
            let colorFunctionName = $0.light.name.lowerCamelCased()
            return """
            @Composable
            @ReadOnlyComposable
            fun Colors.\(colorFunctionName)(): Color = colorResource(id = R.color.\($0.light.name))
            """
        }
        let contents = """
        package \(package)
        
        import androidx.compose.runtime.Composable
        import androidx.compose.runtime.ReadOnlyComposable
        import androidx.compose.ui.graphics.Color
        import androidx.compose.ui.res.colorResource
        import \(xmlResourcePackage).R

        object Colors
        
        \(fileLines.joined(separator: "\n\n"))
        
        """
        let data = contents.data(using: .utf8)!
        
        let destination = Destination(directory: outputDirectory, file: fileURL)
        return FileContents(destination: destination, data: data)
    }
    
    private func prepareColorsDotXMLContents(_ colorPairs: [AssetPair<Color>], dark: Bool) -> Data {
        let resources = XMLElement(name: "resources")
        let xml = XMLDocument(rootElement: resources)
        xml.version = "1.0"
        xml.characterEncoding = "utf-8"
        
        colorPairs.forEach { colorPair in
            let hex = (dark && colorPair.dark != nil) ? colorPair.dark!.hex : colorPair.light.hex
            let colorNode = XMLElement(name: "color", stringValue: hex)
            colorNode.addAttribute(XMLNode.attribute(withName: "name", stringValue: colorPair.light.name) as! XMLNode)
            resources.addChild(colorNode)
        }
        
        return xml.xmlData(options: .nodePrettyPrint)
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
