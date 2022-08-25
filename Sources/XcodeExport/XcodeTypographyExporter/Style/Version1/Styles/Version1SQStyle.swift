//
//  Version1SQStyle.swift
//  
//
//  Created by Ivan Mikhailovskii on 25.08.2022.
//

import Foundation
import FigmaExportCore

struct Version1SQStyle {

    static func configure(folderURL: URL) throws -> FileContents {
        let content = """
        \(header)

        import UIKit

        protocol Style {

            func build()
        }

        protocol UIStyle: Style {

            associatedtype Element

            var style: Element { get }

            func resetStyle()
        }

        class SQStyle: NSObject {

            var element: Style?
            var font: UIFont?

            var lineHeight: CGFloat?
            var letterSpacing: CGFloat?

            var strikethroughStyle: NSUnderlineStyle?
            var underlineStyle: NSUnderlineStyle?

            var textAlignment: NSTextAlignment?
            var lineBreakMode: NSLineBreakMode?

            override init() {
                super.init()
            }

            init(element: Style) {
                super.init()

                self.element = element
            }

            func build() {
                self.element?.build()
            }

            @discardableResult
            func textStyle(_ style: SQFontStyle) -> Self {
                let fontStyle = style.fontStyle

                self.font = fontStyle.font
                self.letterSpacing = fontStyle.letterSpacing
                self.lineHeight = fontStyle.lineHeight

                return self
            }

            @discardableResult
            func alignment(_ alignment: NSTextAlignment) -> Self {
                self.textAlignment = alignment
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

            func convertStringToAttributed(
                _ string: String,
                defaultLineBreakMode: NSLineBreakMode? = nil,
                defaultAlignment: NSTextAlignment? = nil
            ) -> NSAttributedString {
                self.convertStringToAttributed(
                    NSAttributedString(string: string),
                    defaultLineBreakMode: defaultLineBreakMode,
                    defaultAlignment: defaultAlignment
                )
            }

            func convertStringToAttributed(
                _ string: NSAttributedString,
                defaultLineBreakMode: NSLineBreakMode? = nil,
                defaultAlignment: NSTextAlignment? = nil,
                isDefaultLineHeight: Bool = false
            ) -> NSAttributedString {

                let paragraphStyle = NSMutableParagraphStyle()
                let attributedString = NSMutableAttributedString(attributedString: string)

                if !isDefaultLineHeight,
                   let lineHeight = self.lineHeight,
                   let font = self.font {
                    paragraphStyle.minimumLineHeight = lineHeight
                    paragraphStyle.maximumLineHeight = lineHeight

                    let adjustment = lineHeight > font.lineHeight ? 2.0 : 1.0
                    let baselineOffset = (lineHeight - font.lineHeight) / 2.0 / adjustment

                    attributedString.addAttribute(.baselineOffset, value: baselineOffset,
                                                  range: NSMakeRange(.zero, attributedString.length))
                }

                if let lineBreakMode = self.lineBreakMode ?? defaultLineBreakMode {
                    paragraphStyle.lineBreakMode = lineBreakMode
                }

                if let alignment = self.textAlignment ?? defaultAlignment {
                    paragraphStyle.alignment = alignment
                }

                attributedString.addAttribute(NSAttributedString.Key.paragraphStyle,
                                              value: paragraphStyle,
                                              range: NSMakeRange(.zero, attributedString.length))

                if let strikethroughStyle = self.strikethroughStyle {
                    attributedString.addAttribute(NSAttributedString.Key.strikethroughStyle,
                                                  value: strikethroughStyle.rawValue,
                                                  range: NSMakeRange(.zero, attributedString.length))
                }

                if let underlineStyle = self.underlineStyle {
                    attributedString.addAttribute(NSAttributedString.Key.underlineStyle,
                                                  value: underlineStyle.rawValue,
                                                  range: NSMakeRange(.zero, attributedString.length))
                }

                if let letterSpacing = self.letterSpacing {
                    attributedString.addAttribute(NSAttributedString.Key.kern,
                                                  value: letterSpacing,
                                                  range: NSMakeRange(.zero, attributedString.length))
                }


                return attributedString
            }
        }
        """

        return try XcodeTypographyExporter.makeFileContents(
            data: content,
            directoryURL: folderURL,
            fileName: "SQStyle.swift"
        )
    }
}

