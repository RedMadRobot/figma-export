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

    func createSQStyleTextInput(textStyles: [TextStyle], folderURL: URL) throws -> FileContents {
        let stringsLabel: [String] = textStyles.map {
            self.convertStyle(fromTextStyle: $0, type: .textInputStyleName)
        }

        let content = """
        \(header)

        import UIKit

        class \(String.textInputStyleName): SQStyle {

            var _placeholderColor: UIColor?
            var _cursorColor: UIColor?

            \(stringsLabel.joined(separator: "\n\n"))

            \(self.alignments(forStyle: .textInputStyleName))

            \(self.lineBreaks(forStyle: .textInputStyleName))

            \(self.strikethroughTypes(forStyle: .textInputStyleName))

            \(self.underlineTypes(forStyle: .textInputStyleName))

            @objc lazy var textColor = { (color: UIColor?) -> \(String.textInputStyleName) in
                self._textColor = color
                return self
            }

            @objc lazy var placeholderColor = { (color: UIColor?) -> \(String.textInputStyleName) in
                self._placeholderColor = color
                return self
            }

            @objc lazy var cursorColor = { (color: UIColor?) -> \(String.textInputStyleName) in
                self._cursorColor = color
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
        }
        """

        return try self.makeFileContents(
            data: content,
            directoryURL: folderURL,
            fileName: "SQStyleTextInput.swift"
        )
    }
}

