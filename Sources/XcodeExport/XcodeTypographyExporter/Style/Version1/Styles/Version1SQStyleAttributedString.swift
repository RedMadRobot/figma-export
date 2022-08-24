//
//  Version1SQStyleAttributedString.swift
//  
//
//  Created by Ivan Mikhailovskii on 24.08.2022.
//

import Foundation
import FigmaExportCore

struct Version1SQStyleAttributedString {

    static func configure(
        folderURL: URL
    ) throws -> FileContents {

        let content = """
        \(header)

        import UIKit

        class \(String.attributedStringStyleName): SQStyle {

            @discardableResult
            func font(_ style: FontStyle) -> Self {
                let fontStyle = style.fontStyle

                self.font = fontStyle.font
                self.letterSpacing = fontStyle.letterSpacing
                self.lineHeight = fontStyle.lineHeight

                return self
            }

            @discardableResult
            func alignment(_ alignment: NSTextAlignment) -> Self {
                self.textAlignment = alignment
                return self
            }

            @discardableResult
            func lineBreakMode(_ lineBreakMode: NSLineBreakMode) -> Self {
                self.lineBreakMode = lineBreakMode
                return self
            }

            @discardableResult
            func strikethroughStyle(_ strikethroughStyle: NSUnderlineStyle) -> Self {
                self.strikethroughStyle = strikethroughStyle
                return self
            }

            @discardableResult
            func underlineStyle(_ underlineStyle: NSUnderlineStyle) -> Self {
                self.underlineStyle = underlineStyle
                return self
            }

            @discardableResult
            func textColor(_ color: UIColor?) -> Self {
                self._textColor = color
                return self
            }

            override func convertStringToAttributed(
                _ string: NSAttributedString,
                defaultLineBreakMode: NSLineBreakMode? = nil,
                defaultAlignment: NSTextAlignment? = nil,
                isDefaultLineHeight: Bool = false
            ) -> NSAttributedString {
                let attributedString = NSMutableAttributedString(
                    attributedString: super.convertStringToAttributed(
                        string,
                        defaultLineBreakMode: defaultLineBreakMode,
                        defaultAlignment: defaultAlignment,
                        isDefaultLineHeight: isDefaultLineHeight
                    )
                )

                if let font = self.font {
                    attributedString.addAttribute(NSAttributedString.Key.font,
                                                  value: font,
                                                  range: NSMakeRange(.zero, attributedString.length))
                }

                if let color = self._textColor {
                    attributedString.addAttribute(NSAttributedString.Key.foregroundColor,
                                                  value: color,
                                                  range: NSMakeRange(.zero, attributedString.length))
                }

                return attributedString
            }
        }

        """

        return try XcodeTypographyExporter.makeFileContents(
            data: content,
            directoryURL: folderURL,
            fileName: String.attributedStringStyleName + ".swift"
        )
    }
}
