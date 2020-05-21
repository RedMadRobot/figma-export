import Foundation
import FigmaExportCore

final public class XcodeColorExporter {

    private let output: XcodeColorsOutput

    public init(output: XcodeColorsOutput) {
        self.output = output
    }
    
    public func export(colorPairs: [AssetPair<Color>]) -> [FileContents] {
        var files: [FileContents] = []
        
        // Sources/.../Color.swift
        let contents = prepareColorDotSwiftContents(colorPairs)
        let contentsData = contents.data(using: .utf8)!
        
        let fileURL = URL(string: output.colorSwiftURL.lastPathComponent)!
        let directoryURL = output.colorSwiftURL.deletingLastPathComponent()
        
        files.append(
            FileContents(
                destination: Destination(directory: directoryURL, file: fileURL),
                data: contentsData
            )
        )
        
        // Assets.xcassets/Colors/Contents.json
        let contentsJson = XcodeEmptyContents()
        files.append(FileContents(
            destination: Destination(directory: output.assetsColorsURL, file: contentsJson.fileURL),
            data: contentsJson.data
        ))
        
        // Assets.xcassets/Colors/***.colorset/Contents.json
        colorPairs.forEach { colorPair in
            let name = colorPair.light.name
            let dirURL = output.assetsColorsURL.appendingPathComponent("\(name).colorset")
            
            var colors: [XcodeAssetContents.ColorData] = [
                XcodeAssetContents.ColorData(
                    appearances: nil,
                    color: XcodeAssetContents.ColorInfo(
                        components: colorPair.light.toComponents())
                )
            ]
            if let darkColor = colorPair.dark {
                colors.append(
                    XcodeAssetContents.ColorData(
                        appearances: [XcodeAssetContents.DarkAppeareance()],
                        color: XcodeAssetContents.ColorInfo(
                            components: darkColor.toComponents())
                    )
                )
            }
            
            let contents = XcodeAssetContents(colors: colors)
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try! encoder.encode(contents)
            let fileURL = URL(string: "Contents.json")!
            files.append(FileContents(
                destination: Destination(directory: dirURL, file: fileURL),
                data: data
            ))
        }
        
        return files
    }
    
    private func prepareColorDotSwiftContents(_ colorPairs: [AssetPair<Color>]) -> String {
        var contents = """
        import UIKit
        
        extension UIColor {
        
        """
        
        colorPairs.forEach { colorPair in
            contents.append("    static var \(colorPair.light.name): UIColor { return UIColor(named: #function)! }\n")
        }
        contents.append("\n}\n")
        
        return contents
    }
}

private extension Color {
    func toComponents() -> XcodeAssetContents.Components {
        let red = "0x\(doubleToHex(self.red))"
        let green = "0x\(doubleToHex(self.green))"
        let blue = "0x\(doubleToHex(self.blue))"
        let alpha = String(format: "%.3F", arguments: [self.alpha])
        return XcodeAssetContents.Components(red: red, alpha: alpha, green: green, blue: blue)
    }

    func doubleToHex(_ double: Double) -> String {
        String(format: "%02X", arguments: [Int((double * 255).rounded())])
    }
}
