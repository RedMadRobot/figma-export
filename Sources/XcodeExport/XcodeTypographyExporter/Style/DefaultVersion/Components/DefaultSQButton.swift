//
//  DefaultSQButton.swift
//  
//
//  Created by Ivan Mikhailovskii on 23.08.2022.
//

import Foundation
import FigmaExportCore

struct DefaultSQButton {

    static func configure(folderURL: URL) throws -> FileContents {
        let content = """
        \(header)

        import UIKit

        @IBDesignable class SQButton: UIButton, UIStyle {

            typealias Element = \(String.buttonStyleName)

            internal var _style: Element?

            var style: Element {
                if let style = self._style {
                    return style
                }
                let style = Element(element: self)
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

            override func setTitle(_ title: String?, for state: UIControl.State) {
                super.setTitle(title, for: state)

                self.updateAttributedText()
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
                self._style = Element(element: self)
            }

            func updateTintColor() {
                self.tintColor = self.style.tintColor(forState: self.state)
            }

            func updateBorders() {
                self.layer.borderColor = self.style.borderColor(forState: self.state)?.cgColor
                self.layer.borderWidth = self.style.borerWidth(forState: self.state)
            }

            private func updateAttributedText() {
                let attributedString: NSAttributedString
                if let buttonAttributedText = self.titleLabel?.attributedText {
                    attributedString = buttonAttributedText
                } else {
                    attributedString = NSAttributedString(string: self.titleLabel?.text ?? "")
                }

                self.titleLabel?.attributedText = self.style.convertStringToAttributed(
                    attributedString
                )
                self.invalidateIntrinsicContentSize()
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

        return try XcodeTypographyExporter.makeFileContents(
            data: content,
            directoryURL: folderURL,
            fileName: "SQButton.swift"
        )
    }
}

