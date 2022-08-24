//
//  Version1SQStyleLabel.swift
//  
//
//  Created by Ivan Mikhailovskii on 24.08.2022.
//

import Foundation
import FigmaExportCore

struct Version1SQStyleLabel {

    static func configure(
        folderURL: URL
    ) throws -> FileContents {

        let content = """
        \(header)

        import UIKit

        class \(String.labelStyleName): SQStyle {

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

            @discardableResult
            func textColor(_ color: UIColor?) -> Self {
                self._textColor = color
                return self
            }
        }
        """

        return try XcodeTypographyExporter.makeFileContents(
            data: content,
            directoryURL: folderURL,
            fileName: String.labelStyleName + ".swift"
        )
    }
}
