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

            typealias Element = \(String.labelStyleName)

            private var _style: Element?

            var style: Element {
                if let style = self._style {
                    return style
                }
                let style = Element(element: self)
                self._style = style
                return style
            }

            override var text: String? {
                didSet {
                    self.updateAttributedText()
                }
            }

            @IBInspectable var styleFont: String = "" {
                didSet {
                    self.style.safeValue(forKey: self.styleFont)
                    self.updateAttributedText()
                }
            }

            func build() {
                self.font = self.style?.font
                self.textColor = self.style?._textColor
                self.updateAttributedText()
            }

            func resetStyle() {
                self._style = Element(element: self)
            }

            private func updateAttributedText() {
                let attributedString: NSAttributedString
                if let labelAttributedText = self.attributedText {
                    attributedString = labelAttributedText
                } else {
                    attributedString = NSAttributedString(string: self.text ?? "")
                }

                self.attributedText = self.style.convertStringToAttributed(
                    attributedString,
                    defaultLineBreakMode: self.lineBreakMode,
                    defaultAlignment: self.textAlignment
                )
                self.invalidateIntrinsicContentSize()
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
