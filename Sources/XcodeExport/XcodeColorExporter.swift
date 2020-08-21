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
        let contents = prepareColorDotSwiftContents(colorPairs, formAsset: output.assetsColorsURL != nil)
        let contentsData = contents.data(using: .utf8)!
        
        let fileURL = URL(string: output.colorSwiftURL.lastPathComponent)!
        let directoryURL = output.colorSwiftURL.deletingLastPathComponent()
        
        files.append(
            FileContents(
                destination: Destination(directory: directoryURL, file: fileURL),
                data: contentsData
            )
        )
        
        guard let assetsColorsURL = output.assetsColorsURL else { return files }
        
        // Assets.xcassets/Colors/Contents.json
        let contentsJson = XcodeEmptyContents()
        files.append(FileContents(
            destination: Destination(directory: assetsColorsURL, file: contentsJson.fileURL),
            data: contentsJson.data
        ))
        
        // Assets.xcassets/Colors/***.colorset/Contents.json
        colorPairs.forEach { colorPair in
            let name = colorPair.light.name
            let dirURL = assetsColorsURL.appendingPathComponent("\(name).colorset")
            
            var colors: [XcodeAssetContents.ColorData] = [
                XcodeAssetContents.ColorData(
                    appearances: nil,
                    color: XcodeAssetContents.ColorInfo(
                        components: colorPair.light.toHexComponents())
                )
            ]
            if let darkColor = colorPair.dark {
                colors.append(
                    XcodeAssetContents.ColorData(
                        appearances: [XcodeAssetContents.DarkAppeareance()],
                        color: XcodeAssetContents.ColorInfo(
                            components: darkColor.toHexComponents())
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
    
    private func prepareColorDotSwiftContents(_ colorPairs: [AssetPair<Color>], formAsset: Bool) -> String {
        var contents = """
        import UIKit
        
        extension UIColor {
        
        """
        
        colorPairs.forEach { colorPair in
            if formAsset {
                contents.append("    static var \(colorPair.light.name): UIColor { return UIColor(named: #function)! }\n")
            } else {
                let lightComponents = colorPair.light.toRgbComponents()
                if let darkComponents = colorPair.dark?.toRgbComponents() {
                    contents.append("""
                        static var \(colorPair.light.name): UIColor {
                            if #available(iOS 13.0, *) {
                                return UIColor { traitCollection -> UIColor in
                                    if traitCollection.userInterfaceStyle == .dark {
                                        return UIColor(red: \(darkComponents.red), green: \(darkComponents.green), blue: \(darkComponents.blue), alpha: \(darkComponents.alpha))
                                    } else {
                                        return UIColor(red: \(lightComponents.red), green: \(lightComponents.green), blue: \(lightComponents.blue), alpha: \(lightComponents.alpha))
                                    }
                                }
                            } else {
                                return UIColor(red: \(lightComponents.red), green: \(lightComponents.green), blue: \(lightComponents.blue), alpha: \(lightComponents.alpha))
                            }
                        }\n
                    """)
                } else {
                    contents.append("""
                        static var \(colorPair.light.name): UIColor {
                            return UIColor(red: \(lightComponents.red), green: \(lightComponents.green), blue: \(lightComponents.blue), alpha: \(lightComponents.alpha))
                        }\n
                    """)
                }
            }
        }
        contents.append("\n}\n")
        
        return contents
    }
}

private extension Color {
    func toHexComponents() -> XcodeAssetContents.Components {
        let red = "0x\(doubleToHex(self.red))"
        let green = "0x\(doubleToHex(self.green))"
        let blue = "0x\(doubleToHex(self.blue))"
        let alpha = String(format: "%.3F", arguments: [self.alpha])
        return XcodeAssetContents.Components(red: red, alpha: alpha, green: green, blue: blue)
    }

    func doubleToHex(_ double: Double) -> String {
        String(format: "%02X", arguments: [Int((double * 255).rounded())])
    }
    
    func toRgbComponents() -> XcodeAssetContents.Components {
        let red = String(format: "%.3F", arguments: [self.red])
        let green = String(format: "%.3F", arguments: [self.green])
        let blue = String(format: "%.3F", arguments: [self.blue])
        let alpha = String(format: "%.3F", arguments: [self.alpha])
        return XcodeAssetContents.Components(red: red, alpha: alpha, green: green, blue: blue)
    }
}
