import Foundation
import FigmaExportCore
import Stencil

final public class XcodeTypographyExporter {

    public init() {}
    
    public func exportStyles(_ textStyles: [TextStyle], folderURL: URL) throws -> [FileContents] {
        return [
            try self.createSQStyle(folderURL: folderURL),
            try self.createSQStyleLabel(textStyles: textStyles, folderURL: folderURL),
            try self.createSQStyleButton(textStyles: textStyles, folderURL: folderURL)
        ]
    }

    public func exportComponents(textStyles: [TextStyle], componentsDirectory: URL) throws -> [FileContents] {
        let dict = textStyles.map { style -> [String: Any] in
            let type: String = style.name
            return [
                "className": style.name.first!.uppercased() + style.name.dropFirst(),
                "varName": style.name,
                "size": style.fontSize,
                "supportsDynamicType": true,
                "type": type,
                "tracking": style.letterSpacing,
                "lineHeight": style.lineHeight ?? 0
            ]
        }
        
        return [
            try self.createSQLabel(folderURL: componentsDirectory),
            try self.createSQButton(folderURL: componentsDirectory)
        ]
    }

    public func exportFonts(textStyles: [TextStyle], swiftUIFontExtensionURL: URL) throws -> [FileContents] {
        let strings: [String] = textStyles.map {
            return """
                static func \($0.name)() -> Font {
                    Font.custom("\($0.fontName)", size: \($0.fontSize))
                }
            """
        }

        let contents = """
        \(header)

        import SwiftUI

        public extension Font {

        \(strings.joined(separator: "\n"))
        }
        """

        let data = contents.data(using: .utf8)!

        let fileURL = URL(string: swiftUIFontExtensionURL.lastPathComponent)!
        let directoryURL = swiftUIFontExtensionURL.deletingLastPathComponent()

        let destination = Destination(directory: directoryURL, file: fileURL)
        return [FileContents(destination: destination, data: data)]
    }

    internal func convertStyle(fromTextStyle textStyle: TextStyle, type: String) -> String {
        var params: [String] = [
            "self.font = self.customFont(\"\(textStyle.fontName)\", size: \(textStyle.fontSize))",
            "self.letterSpacing = \(textStyle.letterSpacing)"
        ]
        if let lineHeight = textStyle.lineHeight {
            params.append("self.lineHeight = \(lineHeight)")
        }
        return """
            @objc lazy var \(textStyle.name): \(type) = {
                \(params.joined(separator: "\n         "))
                return self
            }()
        """
    }
    
    internal func makeFileContents(data: String, directoryURL: URL, fileName: String) throws -> FileContents {
        let data = data.data(using: .utf8)!
        let fileURL = URL(string: fileName)!
        let destination = Destination(directory: directoryURL, file: fileURL)
        return FileContents(destination: destination, data: data)
    }
}
