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

    func createSQButton(folderURL: URL) throws -> FileContents {
        let content = """
        \(header)

        import UIKit

        @IBDesignable class SQButton: UIButton, UIStyle {

            typealias Element = SQStyleButton

            private var _style: SQStyleButton?

            var style: SQStyleButton {
                if let style = self._style {
                    return style
                }
                let style = SQStyleButton(element: self)
                self._style = style
                return style
            }

            override var isHighlighted: Bool {
                didSet {
                    self.updateTintColor()
                    self.updateBorders()
                }
            }

            override var isSelected: Bool {
                didSet {
                    self.updateTintColor()
                    self.updateBorders()
                }
            }

            override var isEnabled: Bool {
                didSet {
                    self.updateTintColor()
                    self.updateBorders()
                }
            }

            @IBInspectable var styleFont: String = "" {
                didSet {
                    self.style.safeValue(forKey: self.styleFont)
                    self.updateAttributedText()
                }
            }

            func build() {
                let controlStates: [UIControl.State] = [.normal, .highlighted, .selected, .disabled]

                self.titleLabel?.font = self.style.font
                controlStates.forEach { state in
                    if let textColor = self.style.textColor(forState: state) {
                        self.setTitleColor(textColor, for: state)
                    }
                    if let backgroundColor = self.style.backgroundColor(forState: state) {
                        self.setBackgroundImage(UIImage.image(withColor: backgroundColor), for: state)
                    }
                }
                self.updateTintColor()
                self.updateBorders()
            }

            func resetStyle() {
                self._style = SQStyleButton(element: self)
            }

            func updateTintColor() {
                self.tintColor = self.style.tintColor(forState: self.state)
            }

            func updateBorders() {
                self.layer.borderColor = self.style.borderColor(forState: self.state)?.cgColor
                self.layer.borderWidth = self.style.borerWidth(forState: self.state)
            }

            private func updateAttributedText() {
                let paragraphStyle = NSMutableParagraphStyle()
                if let lineHeight = self.style.lineHeight,
                   let font = self.style.font {
                    let lineHeightMultiple = ((100.0 * lineHeight) / font.lineHeight) / 100
                    paragraphStyle.lineHeightMultiple = lineHeightMultiple
                }

                let attributedString: NSMutableAttributedString
                if let labelAttributedText = self.titleLabel?.attributedText {
                    attributedString = NSMutableAttributedString(attributedString: labelAttributedText)
                } else {
                    attributedString = NSMutableAttributedString(string: self.titleLabel?.text ?? "")
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

                self.titleLabel?.attributedText = attributedString
                invalidateIntrinsicContentSize()
            }

        }

        extension UIImage {

            static func image(
                withColor color: UIColor?,
                rect: CGRect = CGRect(x: 0, y: 0, width: 1, height: 1)
            ) -> UIImage {
                UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
                color?.setFill()
                UIRectFill(rect)
                let image = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
                UIGraphicsEndImageContext()
                return image
            }
        }

        """

        return try self.makeFileContents(
            data: content,
            directoryURL: folderURL,
            fileName: "SQButton.swift"
        )
    }
}

