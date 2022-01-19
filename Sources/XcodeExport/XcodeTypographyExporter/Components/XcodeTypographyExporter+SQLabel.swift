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
