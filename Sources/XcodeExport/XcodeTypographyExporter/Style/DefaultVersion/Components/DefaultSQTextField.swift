//
//  DefaultSQTextField.swift
//  
//
//  Created by Ivan Mikhailovskii on 23.08.2022.
//

import Foundation
import FigmaExportCore

struct DefaultSQTextField {

    static func configure(folderURL: URL) throws -> FileContents {
        let content = """
        \(header)

        import UIKit

        @IBDesignable class SQTextField: UITextField, UIStyle {

            typealias Element = \(String.textInputStyleName)

            private var _style: Element?

            var style: Element {
                if let style = self._style {
                    return style
                }
                let style = Element(element: self)
                self._style = style
                return style
            }

            @IBInspectable var styleFont: String = "" {
                didSet {
                    self.style.safeValue(forKey: self.styleFont)
                    self.updateText()
                }
            }

            override open var isEnabled: Bool {
                didSet {
                    self.updateText()
                    self.updateBorders()
                }
            }

            override open var text: String? {
                didSet {
                    self.updateText()
                }
            }

            override open var placeholder: String? {
                didSet {
                    if self.style._placeholderStyle != nil {
                        self.updatePlaceholder()
                    }
                }
            }

            open override func textRect(forBounds bounds: CGRect) -> CGRect {
                return bounds.inset(by: self.style._textInsets)
            }

            open override func editingRect(forBounds bounds: CGRect) -> CGRect {
                return bounds.inset(by: self.style._textInsets)
            }

            open override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
                return bounds.inset(by: self.style._textInsets)
            }

            open override func drawText(in rect: CGRect) {
                super.drawText(in: rect.inset(by: self.style._textInsets))
            }

            func build() {
                self.tintColor = self.style._cursorColor

                self.setNeedsDisplay()
                self.updateText()
                self.updateBorders()
                self.updatePlaceholder()
            }

            func resetStyle() {
                self._style = Element(element: self)
            }

            internal func updateBorders() {
                self.layer.borderColor = self.style.borderColor(forState: self.state)?.cgColor
                self.layer.borderWidth = self.style.borerWidth(forState: self.state)
            }

            internal func updateText() {
                self.defaultTextAttributes = [ : ]

                if let strikethroughStyle = self.style.strikethroughStyle {
                    self.defaultTextAttributes[.strikethroughStyle] = strikethroughStyle
                }

                if let underlineStyle = self.style.underlineStyle {
                    self.defaultTextAttributes[.underlineStyle] = underlineStyle
                }

                if let letterSpacing = self.style.letterSpacing {
                    self.defaultTextAttributes[.kern] = letterSpacing
                }

                if let color = self.style.textColor(forState: self.state) ?? self.textColor {
                    self.defaultTextAttributes[.foregroundColor] = color
                }

                if let font = self.style.font {
                    self.defaultTextAttributes[.font] = font
                }

                self.textAlignment = self.style.textAlignment ?? self.textAlignment
            }

            internal func updatePlaceholder() {
                let attributedString: NSAttributedString
                if let labelAttributedText = self.attributedPlaceholder {
                    attributedString = labelAttributedText
                } else {
                    attributedString = NSAttributedString(string: self.placeholder ?? "")
                }

                self.attributedPlaceholder = self.style._placeholderStyle?
                    .convertStringToAttributed(
                    attributedString,
                    isDefaultLineHeight: true
                )
            }
        }

        """

        return try XcodeTypographyExporter.makeFileContents(
            data: content,
            directoryURL: folderURL,
            fileName: "SQTextField.swift"
        )
    }
}

