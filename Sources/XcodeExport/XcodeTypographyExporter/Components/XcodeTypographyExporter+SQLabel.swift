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

    func createSQLabel(folderURL: URL) throws -> FileContents {
        let content = """
        \(header)

        import UIKit

        @IBDesignable class SQLabel: UILabel, UIStyle {

            typealias Element = SQStyleLabel

            private var _style: SQStyleLabel?

            var style: SQStyleLabel {
                if let style = self._style {
                    return style
                }
                let style = SQStyleLabel(element: self)
                self._style = style
                return style
            }

            override var text: String? {
                didSet {
                    if self._style != nil {
                        self.updateAttributedText()
                    }
                }
            }

            override var attributedText: NSAttributedString? {
                didSet {
                    if self._style != nil {
                        self.updateAttributedText()
                    }
                }
            }

            @IBInspectable var styleFont: String = "" {
                didSet {
                    self.style.safeValue(forKey: self.styleFont)
                }
            }

            func build() {
                self.font = self._style?.font
                self.textColor = self._style?._textColor
                self.updateAttributedText()
            }

            func resetStyle() {
                self._style = SQStyleLabel(element: self)
            }

            private func updateAttributedText() {
                let paragraphStyle = NSMutableParagraphStyle()
                if let lineHeight = self.style.lineHeight,
                   let font = self.style.font {
                    let lineHeightMultiple = ((100.0 * lineHeight) / font.lineHeight) / 100
                    paragraphStyle.lineHeightMultiple = lineHeightMultiple
                }

                paragraphStyle.lineBreakMode = self.style.lineBreakMode ?? self.lineBreakMode
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
            fileName: "SQLabel.swift"
        )
    }
}
