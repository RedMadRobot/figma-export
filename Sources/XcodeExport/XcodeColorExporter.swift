import Foundation
import FigmaExportCore

final public class XcodeColorExporter {
    
    private let output: XcodeColorsOutput

    public init(output: XcodeColorsOutput) {
        self.output = output
    }
    
    public func export(colorPairs: [AssetPair<Color>]) -> [FileContents] {
        var files: [FileContents] = []
        
        // UIKit UIColor extension
        if let colorSwiftURL = output.colorSwiftURL {
            
            let contents = prepareColorDotSwiftContents(
                colorPairs,
                formAsset: output.assetsColorsURL != nil,
                objcAttribute: output.addObjcAttribute,
                groupUsingNamespace: output.groupUsingNamespace
            )
            let contentsData = contents.data(using: .utf8)!
            
            let fileURL = URL(string: colorSwiftURL.lastPathComponent)!
            let directoryURL = colorSwiftURL.deletingLastPathComponent()
            
            files.append(
                FileContents(
                    destination: Destination(directory: directoryURL, file: fileURL),
                    data: contentsData
                )
            )
        }
        
        // SwiftUI Color extension
        if let colorSwiftURL = output.swiftuiColorSwiftURL {
            
            let contents = prepareSwiftUIColorDotSwiftContents(colorPairs, groupUsingNamespace: output.groupUsingNamespace)
            let contentsData = contents.data(using: .utf8)!
            
            let fileURL = URL(string: colorSwiftURL.lastPathComponent)!
            let directoryURL = colorSwiftURL.deletingLastPathComponent()
            
            files.append(
                FileContents(
                    destination: Destination(directory: directoryURL, file: fileURL),
                    data: contentsData
                )
            )
        }
        
        guard let assetsColorsURL = output.assetsColorsURL else { return files }
        
        // Assets.xcassets/Colors/Contents.json
        let contentsJson = XcodeEmptyContents()
        files.append(FileContents(
            destination: Destination(directory: assetsColorsURL, file: contentsJson.fileURL),
            data: contentsJson.data
        ))
        
        // Assets.xcassets/Colors/***.colorset/Contents.json
        colorPairs.forEach { colorPair in
            
            var name = colorPair.light.name
            var assetsColorsURL = assetsColorsURL
            
            if output.groupUsingNamespace,
               let lastName = colorPair.light.originalName.split(separator: "/").last {
                name = String(lastName)
                
                colorPair.light.originalName.split(separator: "/")
                    .dropLast()
                    .map { String($0) }
                    .forEach {
                        assetsColorsURL.appendPathComponent($0, isDirectory: true)
                        
                        let contentsJson = XcodeFolderNamespaceContents()
                        files.append(FileContents(
                            destination: Destination(directory: assetsColorsURL, file: contentsJson.fileURL),
                            data: contentsJson.data
                        ))
                    }
            }
            
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
                        appearances: [XcodeAssetContents.DarkAppearance()],
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
    
    private func prepareSwiftUIColorDotSwiftContents(_ colorPairs: [AssetPair<Color>], groupUsingNamespace: Bool) -> String {
        
        let strings = colorPairs.map { colorPair -> String in
            let bundle = output.assetsInMainBundle ? "" : ", bundle: BundleProvider.bundle"
            let named = groupUsingNamespace ? "\"\(colorPair.light.originalName)\"" : "#function"
            return "    static var \(colorPair.light.name): Color { Color(\(named)\(bundle)) }"
        }

        return """
        \(header)
        
        import SwiftUI
        \(output.assetsInMainBundle ? "" : (output.assetsInSwiftPackage ? bundleProviderSwiftPackage : bundleProvider))
        public extension Color {
        \(strings.joined(separator: "\n"))
        }
        
        """
    }
    
    private func prepareColorDotSwiftContents(
        _ colorPairs: [AssetPair<Color>],
        formAsset: Bool,
        objcAttribute: Bool,
        groupUsingNamespace: Bool
    ) -> String {
        var contents = [String]()
        
        colorPairs.forEach { colorPair in
            let content: String
            if formAsset {
                let bundle = output.assetsInMainBundle ? "" : ", in: BundleProvider.bundle, compatibleWith: nil"
                let prefix = objcAttribute ? "@objc " : ""
                let named = groupUsingNamespace ? "\"\(colorPair.light.originalName)\"" : "#function"
                content = "    \(prefix)static var \(colorPair.light.name): UIColor { UIColor(named: \(named)\(bundle))! }"
            } else {
                let lightComponents = colorPair.light.toRgbComponents()
                if let darkComponents = colorPair.dark?.toRgbComponents() {
                    content = """
                        \(objcAttribute ? "@objc " : "")static var \(colorPair.light.name): UIColor {
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
                        }
                    """
                } else {
                    content = """
                        \(objcAttribute ? "@objc " : "")static var \(colorPair.light.name): UIColor {
                            return UIColor(red: \(lightComponents.red), green: \(lightComponents.green), blue: \(lightComponents.blue), alpha: \(lightComponents.alpha))
                        }
                    """
                }
            }
            contents.append(content)
        }
        
        return """
        \(header)

        import UIKit
        \((!output.assetsInMainBundle && formAsset) ? (output.assetsInSwiftPackage ? bundleProviderSwiftPackage : bundleProvider) : "")
        public extension UIColor {
        \(contents.joined(separator: "\n"))
        }
        
        """
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
