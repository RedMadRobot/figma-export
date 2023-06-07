//
//  File.swift
//  
//
//  Created by Semen Kologrivov on 22.09.2022.
//

import Foundation
import FigmaExportCore

struct Version2SQFontStyle {

    public enum Format: String {
        case swift
        case json
    }

    struct Font: Codable {
        let name: String
        let size: Double
        let lineHeight: Double?
        let letterSpacing: Double
    }

    static func configure(
        textStyles: [TextStyle],
        folderURL: URL,
        fileName: String?,
        format: Format?
    ) throws -> FileContents {
        switch format {
        case .swift, .none:
            return try self.createSwiftTypography(
                textStyles: textStyles,
                folderURL: folderURL,
                fileName: fileName
            )

        case .json:
            return try self.createJSONTypography(
                textStyles: textStyles,
                folderURL: folderURL,
                fileName: fileName
            )
        }
    }

    private static func createSwiftTypography(
        textStyles: [TextStyle],
        folderURL: URL,
        fileName: String?
    ) throws -> FileContents {
        let styles = textStyles
            .sorted(by: { $0.name < $1.name })
            .map {
                """
                    static var \($0.name): SQFont {
                        .init(
                            name: "\($0.fontName)",
                            size: \($0.fontSize),
                            letterSpacing: \($0.letterSpacing),
                            lineHeight: \($0.lineHeight ?? $0.fontSize)
                        )
                    }
                """
            }
        let content = """
        \(header)
        //
        //  NOTE: For using the typography styling, import our
        //  module with styled components:
        //
        //  https://gitlab.sequenia.com/ios-development/modules/uicomponents

        import UIKit
        import UIComponents

        extension SQFont {

        \(styles.joined(separator: "\n\n"))

        }
        """

        return try XcodeTypographyExporter.makeFileContents(
            data: content,
            directoryURL: folderURL,
            fileName: fileName ?? "SQFont+DefinedStyles.swift"
        )
    }

    private static func createJSONTypography(
        textStyles: [TextStyle],
        folderURL: URL,
        fileName: String?
    ) throws -> FileContents {
        var jsonStyles = [String: Font]()
        textStyles
            .sorted(by: { $0.name < $1.name })
            .forEach { style in
                jsonStyles[style.name] = .init(
                    name: style.fontName,
                    size: style.fontSize,
                    lineHeight: style.lineHeight,
                    letterSpacing: style.letterSpacing
                )
            }
        print(jsonStyles)

        let encoder = JSONEncoder()
        let jsonData = try encoder.encode(jsonStyles)
        guard let jsonString = jsonData.prettyPrintedJSONString else {
            fatalError("Parsing failed")
        }

        return try XcodeTypographyExporter.makeFileContents(
            data: jsonString as String,
            directoryURL: folderURL,
            fileName: fileName ?? "typography.json"
        )
    }
}

extension Data {
    var prettyPrintedJSONString: NSString? {
        guard let object = try? JSONSerialization.jsonObject(with: self, options: []),
              let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
              let prettyPrintedString = NSString(data: data, encoding: String.Encoding.utf8.rawValue) else { return nil }

        return prettyPrintedString
    }
}

