//
//  Version1SQStyleButton.swift
//  
//
//  Created by Ivan Mikhailovskii on 24.08.2022.
//

import Foundation
import FigmaExportCore

struct Version1SQStyleButton {

    static func configure(
        folderURL: URL
    ) throws -> FileContents {

        let content = """
        \(header)

        import UIKit

        class \(String.buttonStyleName): SQStyle {

            private var textColors = [UIControl.State: UIColor]()
            private var backgroundColors = [UIControl.State: UIColor]()
            private var tintColors = [UIControl.State: UIColor]()
            private var borderColors = [UIControl.State: UIColor]()
            private var borderWidths = [UIControl.State: CGFloat]()

            @discardableResult
            func alignment(_ alignment: NSTextAlignment) -> Self {
                self.textAlignment = alignment
                return self
            }

            @discardableResult
            func font(_ style: SQFontStyle) -> Self {
                let fontStyle = style.fontStyle

                self.font = fontStyle.font
                self.letterSpacing = fontStyle.letterSpacing
                self.lineHeight = fontStyle.lineHeight

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
            func backgroundColor(_ color: UIColor?, forState state: UIControl.State = .normal) -> Self {
                if let bgColor = color {
                    self.backgroundColors[state] = bgColor
                }
                return self
            }

            func backgroundColor(forState state: UIControl.State = .normal) -> UIColor? {
                self.backgroundColors[state] ?? self.backgroundColors[.normal]
            }

            @discardableResult
            func tintColor(_ color: UIColor?, forState state: UIControl.State = .normal) -> Self {
                if let tintColor = color {
                    self.tintColors[state] = tintColor
                }
                return self
            }

            func tintColor(forState state: UIControl.State = .normal) -> UIColor? {
                self.tintColors[state] ?? self.tintColors[.normal]
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

        extension UIControl.State: Hashable {

            public var hashValue: Int {
                return Int(rawValue)
            }
        }
        """

        return try XcodeTypographyExporter.makeFileContents(
            data: content,
            directoryURL: folderURL,
            fileName: String.buttonStyleName + ".swift"
        )
    }
}
