//
//  Version1SQStyleAttributedString.swift
//  
//
//  Created by Ivan Mikhailovskii on 24.08.2022.
//

import Foundation
import FigmaExportCore

struct Version1SQStyleAttributedString {

    static func configure(
        folderURL: URL
    ) throws -> FileContents {

        let content = """
        \(header)

        import UIKit

        class \(String.attributedStringStyleName): SQStyle {

            var _textColor: UIColor?

            @discardableResult
            func textColor(_ color: UIColor?) -> Self {
                self._textColor = color
                return self
            }

            override func convertStringToAttributed(
                _ string: NSAttributedString,
                defaultLineBreakMode: NSLineBreakMode? = nil,
                defaultAlignment: NSTextAlignment? = nil,
                isDefaultLineHeight: Bool = false
            ) -> NSAttributedString {
                let attributedString = NSMutableAttributedString(
                    attributedString: super.convertStringToAttributed(
                        string,
                        defaultLineBreakMode: defaultLineBreakMode,
                        defaultAlignment: defaultAlignment,
                        isDefaultLineHeight: isDefaultLineHeight
                    )
                )

                if let font = self.font {
                    attributedString.addAttribute(NSAttributedString.Key.font,
                                                  value: font,
                                                  range: NSMakeRange(.zero, attributedString.length))
                }

                if let color = self._textColor {
                    attributedString.addAttribute(NSAttributedString.Key.foregroundColor,
                                                  value: color,
                                                  range: NSMakeRange(.zero, attributedString.length))
                }

                return attributedString
            }
        }

        """

        return try XcodeTypographyExporter.makeFileContents(
            data: content,
            directoryURL: folderURL,
            fileName: String.attributedStringStyleName + ".swift"
        )
    }
}
