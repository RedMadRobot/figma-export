import Foundation
import FigmaExportCore
import Stencil

final public class XcodeTypographyExporter {

    public init() {}
    
    public func exportFonts(textStyles: [TextStyle], fontExtensionURL: URL) throws -> [FileContents] {
        let strings: [String] = textStyles.map {
            let dynamicType: String = $0.fontStyle != nil ? ", textStyle: .\($0.fontStyle!.textStyleName), scaled: true" : ""
            return """
                static func \($0.name)() -> UIFont {
                    customFont("\($0.fontName)", size: \($0.fontSize)\(dynamicType))
                }
            """
        }
        let contents = """
        \(header)
        
        import UIKit

        public extension UIFont {
        
        \(strings.joined(separator: "\n\n"))
        
            private static func customFont(
                _ name: String,
                size: CGFloat,
                textStyle: UIFont.TextStyle? = nil,
                scaled: Bool = false) -> UIFont {

                guard let font = UIFont(name: name, size: size) else {
                    print("Warning: Font \\(name) not found.")
                    return UIFont.systemFont(ofSize: size, weight: .regular)
                }
                
                if scaled, let textStyle = textStyle {
                    let metrics = UIFontMetrics(forTextStyle: textStyle)
                    return metrics.scaledFont(for: font)
                } else {
                    return font
                }
            }
        }
        """
        
        let data = contents.data(using: .utf8)!
        
        let fileURL = URL(string: fontExtensionURL.lastPathComponent)!
        let directoryURL = fontExtensionURL.deletingLastPathComponent()
        
        let destination = Destination(directory: directoryURL, file: fileURL)
        return [FileContents(destination: destination, data: data)]
    }
    
    public func exportFonts(textStyles: [TextStyle], swiftUIFontExtensionURL: URL) throws -> [FileContents] {
        let strings: [String] = textStyles.map {
            return """
                static func \($0.name)() -> Font {
                    Font.custom("\($0.fontName)", size: \($0.fontSize))
                }
            """
        }
        
        let contents = """
        \(header)
        
        import SwiftUI

        public extension Font {
            
        \(strings.joined(separator: "\n"))
        }
        """

        let data = contents.data(using: .utf8)!
        
        let fileURL = URL(string: swiftUIFontExtensionURL.lastPathComponent)!
        let directoryURL = swiftUIFontExtensionURL.deletingLastPathComponent()
        
        let destination = Destination(directory: directoryURL, file: fileURL)
        return [FileContents(destination: destination, data: data)]
    }
    
    public func exportLabels(textStyles: [TextStyle], labelsDirectory: URL) throws -> [FileContents] {
        let dict = textStyles.map { style -> [String: Any] in
            let type: String = style.fontStyle?.textStyleName ?? ""
            return [
                "className": style.name.first!.uppercased() + style.name.dropFirst(),
                "varName": style.name,
                "size": style.fontSize,
                "supportsDynamicType": style.fontStyle != nil,
                "type": type,
                "tracking": style.letterSpacing,
                "lineHeight": style.lineHeight ?? 0
            ]}
        let contents = try TEMPLATE_Label_swift.render(["styles": dict])
        
        let labelSwift = try makeFileContents(data: contents, directoryURL: labelsDirectory, fileName: "Label.swift")
        let labelStyleSwift = try makeFileContents(data: labelStyleSwiftContents, directoryURL: labelsDirectory, fileName: "LabelStyle.swift")
        
        return [labelSwift, labelStyleSwift]
    }
    
    private func makeFileContents(data: String, directoryURL: URL, fileName: String) throws -> FileContents {
        let data = data.data(using: .utf8)!
        let fileURL = URL(string: fileName)!
        let destination = Destination(directory: directoryURL, file: fileURL)
        return FileContents(destination: destination, data: data)
    }
}

private let TEMPLATE_Label_swift = Template(templateString: """
\(header)

import UIKit

public class Label: UILabel {

    var style: LabelStyle? { nil }

    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if previousTraitCollection?.preferredContentSizeCategory != traitCollection.preferredContentSizeCategory {
            updateText()
        }
    }

    convenience init(text: String?, textColor: UIColor) {
        self.init()
        self.text = text
        self.textColor = textColor
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
        updateText()
    }

    private func commonInit() {
        font = style?.font
        adjustsFontForContentSizeCategory = true
    }

    private func updateText() {
        text = super.text
    }

    public override var text: String? {
        get {
            guard style?.attributes != nil else {
                return super.text
            }

            return attributedText?.string
        }
        set {
            guard let style = style else {
                super.text = newValue
                return
            }

            guard let newText = newValue else {
                attributedText = nil
                super.text = nil
                return
            }

            let attributes = style.attributes(for: textAlignment, lineBreakMode: lineBreakMode)
            attributedText = NSAttributedString(string: newText, attributes: attributes)
        }
    }

}
{% for style in styles %}
public final class {{ style.className }}Label: Label {

    override var style: LabelStyle? {
        LabelStyle(
            font: UIFont.{{ style.varName }}(){% if style.supportsDynamicType %},
            fontMetrics: UIFontMetrics(forTextStyle: .{{ style.type }}){% endif %}{% if style.lineHeight != 0 %},
            lineHeight: {{ style.lineHeight }}{% endif %}{% if style.tracking != 0 %},
            tracking: {{ style.tracking}}{% endif %}
        )
    }
}
{% endfor %}
""")

private let labelStyleSwiftContents = """
\(header)

import UIKit

struct LabelStyle {

    let font: UIFont
    let fontMetrics: UIFontMetrics?
    let lineHeight: CGFloat?
    let tracking: CGFloat
    
    init(font: UIFont, fontMetrics: UIFontMetrics? = nil, lineHeight: CGFloat? = nil, tracking: CGFloat = 0) {
        self.font = font
        self.fontMetrics = fontMetrics
        self.lineHeight = lineHeight
        self.tracking = tracking
    }
    
    func attributes(for alignment: NSTextAlignment, lineBreakMode: NSLineBreakMode) -> [NSAttributedString.Key: Any] {
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = alignment
        paragraphStyle.lineBreakMode = lineBreakMode
        
        var baselineOffset: CGFloat = .zero
        
        if let lineHeight = lineHeight {
            let scaledLineHeight: CGFloat = fontMetrics?.scaledValue(for: lineHeight) ?? lineHeight
            paragraphStyle.minimumLineHeight = scaledLineHeight
            paragraphStyle.maximumLineHeight = scaledLineHeight
            
            baselineOffset = (scaledLineHeight - font.lineHeight) / 4.0
        }
        
        return [
            NSAttributedString.Key.paragraphStyle: paragraphStyle,
            NSAttributedString.Key.kern: tracking,
            NSAttributedString.Key.baselineOffset: baselineOffset,
            NSAttributedString.Key.font: font
        ]
    }
}
"""
