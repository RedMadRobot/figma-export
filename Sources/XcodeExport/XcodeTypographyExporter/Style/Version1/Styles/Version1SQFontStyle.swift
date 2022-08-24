//
//  Version1SQFontStyle.swift
//  
//
//  Created by Ivan Mikhailovskii on 24.08.2022.
//

import Foundation
import FigmaExportCore

struct Version1SQFontStyle {

    static func configure(textStyles: [TextStyle], folderURL: URL) throws -> FileContents {
        let cases = textStyles.compactMap { "    case \($0.name)" }

        let styles = textStyles.compactMap { self.createFontStyle($0) }

        let content = """
        \(header)

        import UIKit

        enum \(String.fontStyle) {

             struct FontStyle {
                 let font: UIFont
                 let letterSpacing: CGFloat
                 let lineHeight: CGFloat
             }

        \(cases.joined(separator: "\n"))

            var fontStyle: FontStyle {
                switch self {
        \(styles.joined(separator: "\n\n"))
                }
            }

             private func customFont(
                 _ name: String,
                 size: CGFloat
             ) -> UIFont {

                 guard let font = UIFont(name: name, size: size) else {
                     return UIFont.systemFont(ofSize: size, weight: .regular)
                 }

                 return font
             }
        }
        """

        return try XcodeTypographyExporter.makeFileContents(
            data: content,
            directoryURL: folderURL,
            fileName: String.fontStyle + ".swift"
        )
    }

    private static func createFontStyle(_ textStyle: TextStyle) -> String {
        """
                case \(textStyle.name):
                    return FontStyle(
                        font: self.customFont("\(textStyle.fontName)", size: \(textStyle.fontSize)),
                        letterSpacing: \(textStyle.letterSpacing),
                        lineHeight: \(textStyle.lineHeight ?? textStyle.fontSize)
                    )
        """
    }


}
