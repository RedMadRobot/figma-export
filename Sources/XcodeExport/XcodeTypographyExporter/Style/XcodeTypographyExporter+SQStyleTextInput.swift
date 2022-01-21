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

            var _cursorColor: UIColor?
            var _textInsets: UIEdgeInsets = .zero

            private var textColors = [UIControl.State: UIColor]()
            private var borderColors = [UIControl.State: UIColor]()
            private var borderWidths = [UIControl.State: CGFloat]()

            var _placeholderStyle: \(String.attributedStringStyleName)?

        \(stringsLabel.joined(separator: "\n\n    "))

            \(self.alignments(forStyle: .textInputStyleName))

            \(self.lineBreaks(forStyle: .textInputStyleName))

            \(self.strikethroughTypes(forStyle: .textInputStyleName))

            \(self.underlineTypes(forStyle: .textInputStyleName))

            @objc lazy var textColor = { (color: UIColor?) -> \(String.textInputStyleName) in
                self._textColor = color
                return self
            }

            @objc lazy var placeholderStyle = { (style: \(String.attributedStringStyleName) -> \(String.textInputStyleName) in
                self._placeholderStyle = style
                return self
            }

            @objc lazy var cursorColor = { (color: UIColor?) -> \(String.textInputStyleName) in
                self._cursorColor = color
                return self
            }

            @objc lazy var textInsets = { (insets: UIEdgeInsets) -> \(String.textInputStyleName) in
                self._textInsets = insets
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

