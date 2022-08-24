//
//  DefaultSQStyleButton.swift
//  
//
//  Created by Ivan Mikhailovskii on 23.08.2022.
//

import Foundation
import FigmaExportCore

struct DefaultSQStyleButton {

    static func configure(textStyles: [TextStyle], folderURL: URL) throws -> FileContents {

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

            \(stringsButton.joined(separator: "\n\n    "))

            \(self.alignments(forStyle: .buttonStyleName))

            \(self.lineBreaks(forStyle: .buttonStyleName))

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

        return try XcodeTypographyExporter.makeFileContents(
            data: content,
            directoryURL: folderURL,
            fileName: String.buttonStyleName + ".swift"
        )
    }

    private static func alignments(forStyle style: String) -> String {
        """
            @objc lazy var centrerAlignment: \(style) = {
                self.textAlignment = .center
                return self
            }()

            @objc lazy var leftAlignment: \(style) = {
                self.textAlignment = .left
                return self
            }()

            @objc lazy var rightAlignment: \(style) = {
                self.textAlignment = .right
                return self
            }()
        """
    }

    private static func lineBreaks(forStyle style: String) -> String {
        """
            @objc lazy var lineBreakModeByWordWrapping: \(style) = {
                self.lineBreakMode = .byWordWrapping
                return self
            }()

            @objc lazy var lineBreakModeByCharWrapping: \(style) = {
                self.lineBreakMode = .byCharWrapping
                return self
            }()

            @objc lazy var lineBreakModeByClipping: \(style) = {
                self.lineBreakMode = .byClipping
                return self
            }()

            @objc lazy var lineBreakModeByTruncatingHead: \(style) = {
                self.lineBreakMode = .byTruncatingHead
                return self
            }()

            @objc lazy var lineBreakModeByTruncatingTail: \(style) = {
                self.lineBreakMode = .byTruncatingTail
                return self
            }()

            @objc lazy var lineBreakModeByTruncatingMiddle: \(style) = {
                self.lineBreakMode = .byTruncatingMiddle
                return self
            }()
        """
    }

    private static func strikethroughTypes(forStyle style: String) -> String {
        """
            @objc lazy var strikethroughStyleSingle: \(style) = {
                self.strikethroughStyle = .single
                return self
            }()

            @objc lazy var strikethroughStyleThick: \(style) = {
                self.strikethroughStyle = .thick
                return self
            }()

            @objc lazy var strikethroughStyleDouble: \(style) = {
                self.strikethroughStyle = .double
                return self
            }()

            @objc lazy var strikethroughStylePatternDot: \(style) = {
                self.strikethroughStyle = .patternDot
                return self
            }()

            @objc lazy var strikethroughStylePatternDash: \(style) = {
                self.strikethroughStyle = .patternDash
                return self
            }()

            @objc lazy var strikethroughStylePatternDashDot: \(style) = {
                self.strikethroughStyle = .patternDashDot
                return self
            }()

            @objc lazy var strikethroughStylePatternDashDotDot: \(style) = {
                self.strikethroughStyle = .patternDashDotDot
                return self
            }()

            @objc lazy var strikethroughStyleByWord: \(style) = {
                self.strikethroughStyle = .byWord
                return self
            }()
        """
    }

    private static func underlineTypes(forStyle style: String) -> String {
        """
            @objc lazy var underlineStyleSingle: \(style) = {
                self.underlineStyle = .single
                return self
            }()

            @objc lazy var underlineStyleThick: \(style) = {
                self.underlineStyle = .thick
                return self
            }()

            @objc lazy var underlineStyleDouble: \(style) = {
                self.underlineStyle = .double
                return self
            }()

            @objc lazy var underlineStylePatternDot: \(style) = {
                self.underlineStyle = .patternDot
                return self
            }()

            @objc lazy var underlineStylePatternDash: \(style) = {
                self.underlineStyle = .patternDash
                return self
            }()

            @objc lazy var underlineStylePatternDashDot: \(style) = {
                self.underlineStyle = .patternDashDot
                return self
            }()

            @objc lazy var underlineStylePatternDashDotDot: \(style) = {
                self.underlineStyle = .patternDashDotDot
                return self
            }()

            @objc lazy var underlineStyleByWord: \(style) = {
                self.underlineStyle = .byWord
                return self
            }()
        """
    }

    static func convertStyle(fromTextStyle textStyle: TextStyle, type: String) -> String {
        var params: [String] = [
            "self.font = self.customFont(\"\(textStyle.fontName)\", size: \(textStyle.fontSize))",
            "self.letterSpacing = \(textStyle.letterSpacing)"
        ]
        if let lineHeight = textStyle.lineHeight {
            params.append("self.lineHeight = \(lineHeight)")
        }
        return """
            @objc lazy var \(textStyle.name): \(type) = {
                \(params.joined(separator: "\n        "))
                return self
            }()
        """
    }
}
