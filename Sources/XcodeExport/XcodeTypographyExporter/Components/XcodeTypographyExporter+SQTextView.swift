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
                    self.updateAttributedText()
                }
            }

            override var text: String? {
                didSet {
                    self.updateAttributedText()
                }
            }

            func build() {
                self.font = self.style.font
                self.textColor = self.style._textColor
                self.tintColor = self.style._cursorColor

                self.updateAttributedText()
            }

            func resetStyle() {
                self._style = Element(element: self)
            }

            private func updateAttributedText() {
                if self.isEditable { return }

                let attributedString: NSAttributedString
                if let textViewAttributedString = self.attributedText {
                    attributedString = textViewAttributedString
                } else {
                    attributedString = NSAttributedString(string: self.text ?? "")
                }

                self.attributedText = self.style.convertStringToAttributed(
                    attributedString,
                    defaultAlignment: self.textAlignment
                )
                self.invalidateIntrinsicContentSize()
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


