//
//  Version1SQStyleTextInput.swift
//  
//
//  Created by Ivan Mikhailovskii on 24.08.2022.
//

import Foundation
import FigmaExportCore

struct Version1SQStyleTextInput {

    static func configure(
        folderURL: URL
    ) throws -> FileContents {

        let content = """
        \(header)

        import UIKit

        class \(String.textInputStyleName): SQStyle {

            var _cursorColor: UIColor?
            var _textInsets: UIEdgeInsets = .zero

            private var textColors = [UIControl.State: UIColor]()
            private var borderColors = [UIControl.State: UIColor]()
            private var borderWidths = [UIControl.State: CGFloat]()

            var _placeholderStyle: SQStyleAttributedString?

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
            func placeholderStyle(_ style: SQStyleAttributedString) -> Self {
                self._placeholderStyle = style
                return self
            }

            @discardableResult
            func cursorColor(_ color: UIColor?) -> Self {
                self._cursorColor = color
                return self
            }

            @discardableResult
            func textInsets(_ insets: UIEdgeInsets) -> Self {
                self._textInsets = insets
                return self
            }

            @discardableResult
            func textColor(_ color: UIColor?, forState state: UIControl.State = .normal) -> Self {
                if let textColor = color {
                    self.textColors[state] = textColor
                }
                return self
            }

            func textColor(forState state: UIControl.State = .normal) -> UIColor? {
                self.textColors[state] ?? self.textColors[.normal]
            }

            @discardableResult
            func borderColor(_ color: UIColor?, forState state: UIControl.State = .normal) -> Self {
                if let borderColor = color {
                    self.borderColors[state] = borderColor
                }
                return self
            }

            func borderColor(forState state: UIControl.State = .normal) -> UIColor? {
                self.borderColors[state] ?? self.borderColors[.normal]
            }

            @discardableResult
            func borderWidth(_ width: CGFloat, forState state: UIControl.State = .normal) -> Self {
                self.borderWidths[state] = width
                return self
            }

            func borerWidth(forState state: UIControl.State = .normal) -> CGFloat {
                (self.borderWidths[state] ?? self.borderWidths[.normal]) ?? .zero
            }
        }
        """

        return try XcodeTypographyExporter.makeFileContents(
            data: content,
            directoryURL: folderURL,
            fileName: String.textInputStyleName + ".swift"
        )
    }
}

