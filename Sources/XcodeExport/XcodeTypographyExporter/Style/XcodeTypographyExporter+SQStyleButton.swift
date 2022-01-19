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

    func createSQStyleButton(textStyles: [TextStyle], folderURL: URL) throws -> FileContents {
        let stringsButton: [String] = textStyles.map {
            self.convertStyle(fromTextStyle: $0, type: .buttonStyleName)
        }

        let content = """
        \(header)

        import UIKit

        class \(String.buttonStyleName): SQStyle {

            private var textColors = [UIControl.State: UIColor]()
            private var backgroundColors = [UIControl.State: UIColor]()
            private var tintColors = [UIControl.State: UIColor]()
            private var borderColors = [UIControl.State: UIColor]()
            private var borderWidths = [UIControl.State: CGFloat]()

            \(stringsButton.joined(separator: "\n\n"))

            \(self.strikethroughTypes(forStyle: .buttonStyleName))

            \(self.underlineTypes(forStyle: .buttonStyleName))

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

        extension UIControl.State: Hashable {

            public var hashValue: Int {
                return Int(rawValue)
            }
        }
        """

        return try self.makeFileContents(
            data: content,
            directoryURL: folderURL,
            fileName: "SQStyleButton.swift"
        )
    }
}
