//
//  File.swift
//  
//
//  Created by Semen Kologrivov on 19.01.2022.
//

import Foundation
import FigmaExportCore
import Stencil

extension XcodeTypographyExporter {

    func createSQTextView(folderURL: URL) throws -> FileContents {
        let content = """
        \(header)

        import UIKit

        @IBDesignable class SQTextView: UITextView, UIStyle {

            typealias Element = SQStyleTextInput

            private var _style: SQStyleTextInput?

            var style: SQStyleTextInput {
                if let style = self._style {
                    return style
                }
                let style = SQStyleTextInput(element: self)
                self._style = style
                return style
            }

            @IBInspectable var styleFont: String = "" {
                didSet {
                    self.style.safeValue(forKey: self.styleFont)
                    self.updateAttributedText()
                }
            }

            override var text: String? {
                didSet {
                    if self._style != nil {
                        self.updateAttributedText()
                    }
                }
            }

            func build() {
                self.font = self.style.font
                self.textColor = self.style._textColor
                self.tintColor = self.style._cursorColor

                self.updateAttributedText()
            }

            func resetStyle() {
                self._style = SQStyleTextInput(element: self)
            }

            private func updateAttributedText() {
                if self.isEditable { return }

                let paragraphStyle = NSMutableParagraphStyle()
                if let lineHeight = self.style.lineHeight,
                   let font = self.style.font {
                    let lineHeightMultiple = ((100.0 * lineHeight) / font.lineHeight) / 100
                    paragraphStyle.lineHeightMultiple = lineHeightMultiple
                }
                paragraphStyle.alignment = self.style.textAlignment ?? self.textAlignment

                let attributedString: NSMutableAttributedString
                if let labelAttributedText = self.attributedText {
                    attributedString = NSMutableAttributedString(attributedString: labelAttributedText)
                } else {
                    attributedString = NSMutableAttributedString(string: self.text ?? "")
                }

                attributedString.addAttribute(NSAttributedString.Key.paragraphStyle,
                                              value: paragraphStyle,
                                              range: NSMakeRange(.zero, attributedString.length))

                if let strikethroughStyle = self.style.strikethroughStyle {
                    attributedString.addAttribute(NSAttributedString.Key.strikethroughStyle,
                                                  value: strikethroughStyle.rawValue,
                                                  range: NSMakeRange(.zero, attributedString.length))
                }

                if let underlineStyle = self.style.underlineStyle {
                    attributedString.addAttribute(NSAttributedString.Key.underlineStyle,
                                                  value: underlineStyle.rawValue,
                                                  range: NSMakeRange(.zero, attributedString.length))
                }

                if let letterSpacing = self.style.letterSpacing {
                    attributedString.addAttribute(NSAttributedString.Key.kern,
                                                  value: letterSpacing,
                                                  range: NSMakeRange(.zero, attributedString.length))
                }

                self.attributedText = attributedString
                invalidateIntrinsicContentSize()
            }

        }

        """

        return try self.makeFileContents(
            data: content,
            directoryURL: folderURL,
            fileName: "SQTextView.swift"
        )
    }
}


