//
//  DefaultSQStyleLabel.swift
//  
//
//  Created by Ivan Mikhailovskii on 23.08.2022.
//

import Foundation
import FigmaExportCore

struct DefaultSQStyleLabel {

    static func configure(textStyles: [TextStyle], folderURL: URL) throws -> FileContents {

        let stringsLabel: [String] = textStyles.map {
            self.convertStyle(fromTextStyle: $0, type: .labelStyleName)
        }

        let content = """
        \(header)

        import UIKit

        class \(String.labelStyleName): SQStyle {

            \(stringsLabel.joined(separator: "\n\n    "))

            \(self.alignments(forStyle: .labelStyleName))

            \(self.lineBreaks(forStyle: .labelStyleName))

            \(self.strikethroughTypes(forStyle: .labelStyleName))

            \(self.underlineTypes(forStyle: .labelStyleName))

            @objc lazy var textColor = { (color: UIColor?) -> \(String.labelStyleName) in
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
        }
        """

        return try XcodeTypographyExporter.makeFileContents(
            data: content,
            directoryURL: folderURL,
            fileName: "SQStyle.swift"
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
