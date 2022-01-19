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


