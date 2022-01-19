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

    func createSQStyleAttributedString(textStyles: [TextStyle], folderURL: URL) throws -> FileContents {
        let stringsLabel: [String] = textStyles.map {
            self.convertStyle(fromTextStyle: $0, type: .attributedStringStyleName)
        }

        let content = """
        \(header)

        import UIKit

        class \(String.attributedStringStyleName): SQStyle {

            \(stringsLabel.joined(separator: "\n\n    "))

            \(self.alignments(forStyle: .attributedStringStyleName))

            \(self.lineBreaks(forStyle: .attributedStringStyleName))

            \(self.strikethroughTypes(forStyle: .attributedStringStyleName))

            \(self.underlineTypes(forStyle: .attributedStringStyleName))

            @objc lazy var textColor = { (color: UIColor?) -> \(String.attributedStringStyleName) in
                self._textColor = color
                return self
            }

            func safeValue(forKey key: String) {
                let copy = Mirror(reflecting: self)
                for child in copy.children.makeIterator() {
                    if String(describing: child.label) == "Optional(\\"$__lazy_storage_$_\\(key)\\")" {
                        self.value(forKey: key)
                        return
                    }
                }
                fatalError("not font style: \\(key)")
            }

            override func convertStringToAttributed(
                _ string: NSAttributedString,
                defaultLineBreakMode: NSLineBreakMode? = nil,
                defaultAlignment: NSTextAlignment? = nil
            ) -> NSAttributedString {
                let attributedString = NSMutableAttributedString(
                    attributedString: super.convertStringToAttributed(
                        string,
                        defaultLineBreakMode: defaultLineBreakMode,
                        defaultAlignment: defaultAlignment
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

        return try self.makeFileContents(
            data: content,
            directoryURL: folderURL,
            fileName: "SQStyleAttributedString.swift"
        )
    }
}

