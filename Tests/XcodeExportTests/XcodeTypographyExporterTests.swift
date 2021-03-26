import XCTest
import XcodeExport
import FigmaExportCore

final class XcodeTypographyExporterTests: XCTestCase {
    
    func testExportUIKitFonts() throws {
        let output = XcodeTypographyOutput(
            fontExtensionURL: URL(string: "~/UIFont+extension.swift")!
        )
        let exporter = XcodeTypographyExporter(output: output)
        
        let styles = [
            makeTextStyle(name: "largeTitle", fontName: "PTSans-Bold", fontStyle: .largeTitle, fontSize: 34),
            makeTextStyle(name: "header", fontName: "PTSans-Bold", fontSize: 20),
            makeTextStyle(name: "body", fontName: "PTSans-Regular", fontStyle: .body, fontSize: 16),
            makeTextStyle(name: "caption", fontName: "PTSans-Regular", fontStyle: .footnote, fontSize: 14, lineHeight: 20)
        ]
        let files = try exporter.export(textStyles: styles)
        
        let contents = """
        //
        //  The code generated using FigmaExport — Command line utility to export
        //  colors, typography, icons and images from Figma to Xcode project.
        //
        //  https://github.com/RedMadRobot/figma-export
        //
        //  Don’t edit this code manually to avoid runtime crashes
        //

        import UIKit

        public extension UIFont {
        
            static func largeTitle() -> UIFont {
                customFont("PTSans-Bold", size: 34.0, textStyle: .largeTitle, scaled: true)
            }
        
            static func header() -> UIFont {
                customFont("PTSans-Bold", size: 20.0)
            }
        
            static func body() -> UIFont {
                customFont("PTSans-Regular", size: 16.0, textStyle: .body, scaled: true)
            }
        
            static func caption() -> UIFont {
                customFont("PTSans-Regular", size: 14.0, textStyle: .footnote, scaled: true)
            }

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
        
        files.forEach {
            print(String(data: $0.data!, encoding: .utf8)!)
        }
        
        XCTAssertEqual(
            files,
            [
                FileContents(
                    destination: Destination(
                        directory: URL(string: "~/")!,
                        file: URL(string: "UIFont+extension.swift")!
                    ),
                    data: contents.data(using: .utf8)!
                )
            ]
        )
    }

    func testExportUIKitFontsWithObjc() throws {
        let output = XcodeTypographyOutput(
            fontExtensionURL: URL(string: "~/UIFont+extension.swift")!,
            addObjcAttribute: true
        )
        let exporter = XcodeTypographyExporter(output: output)

        let styles = [
            makeTextStyle(name: "largeTitle", fontName: "PTSans-Bold", fontStyle: .largeTitle, fontSize: 34),
            makeTextStyle(name: "header", fontName: "PTSans-Bold", fontSize: 20),
            makeTextStyle(name: "body", fontName: "PTSans-Regular", fontStyle: .body, fontSize: 16),
            makeTextStyle(name: "caption", fontName: "PTSans-Regular", fontStyle: .footnote, fontSize: 14, lineHeight: 20)
        ]
        let files = try exporter.export(textStyles: styles)

        let contents = """
        //
        //  The code generated using FigmaExport — Command line utility to export
        //  colors, typography, icons and images from Figma to Xcode project.
        //
        //  https://github.com/RedMadRobot/figma-export
        //
        //  Don’t edit this code manually to avoid runtime crashes
        //

        import UIKit

        public extension UIFont {

            @objc static func largeTitle() -> UIFont {
                customFont("PTSans-Bold", size: 34.0, textStyle: .largeTitle, scaled: true)
            }

            @objc static func header() -> UIFont {
                customFont("PTSans-Bold", size: 20.0)
            }

            @objc static func body() -> UIFont {
                customFont("PTSans-Regular", size: 16.0, textStyle: .body, scaled: true)
            }

            @objc static func caption() -> UIFont {
                customFont("PTSans-Regular", size: 14.0, textStyle: .footnote, scaled: true)
            }

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

        files.forEach {
            print(String(data: $0.data!, encoding: .utf8)!)
        }

        XCTAssertEqual(
            files,
            [
                FileContents(
                    destination: Destination(
                        directory: URL(string: "~/")!,
                        file: URL(string: "UIFont+extension.swift")!
                    ),
                    data: contents.data(using: .utf8)!
                )
            ]
        )
    }
    
    func testExportSwiftUIFonts() throws {
        let output = XcodeTypographyOutput(
            swiftUIFontExtensionURL: URL(string: "~/Font+extension.swift")!
        )
        let exporter = XcodeTypographyExporter(output: output)
        
        let styles = [
            makeTextStyle(name: "largeTitle", fontName: "PTSans-Bold", fontStyle: .largeTitle, fontSize: 34),
            makeTextStyle(name: "header", fontName: "PTSans-Bold", fontSize: 20),
            makeTextStyle(name: "body", fontName: "PTSans-Regular", fontStyle: .body, fontSize: 16),
            makeTextStyle(name: "caption", fontName: "PTSans-Regular", fontStyle: .footnote, fontSize: 14, lineHeight: 20)
        ]

        let files = try exporter.export(textStyles: styles)

        let contents = """
        //
        //  The code generated using FigmaExport — Command line utility to export
        //  colors, typography, icons and images from Figma to Xcode project.
        //
        //  https://github.com/RedMadRobot/figma-export
        //
        //  Don’t edit this code manually to avoid runtime crashes
        //

        import SwiftUI

        public extension Font {
            
            static func largeTitle() -> Font {
                Font.custom("PTSans-Bold", size: 34.0)
            }
            static func header() -> Font {
                Font.custom("PTSans-Bold", size: 20.0)
            }
            static func body() -> Font {
                Font.custom("PTSans-Regular", size: 16.0)
            }
            static func caption() -> Font {
                Font.custom("PTSans-Regular", size: 14.0)
            }
        }
        """
        
        files.forEach {
            print(String(data: $0.data!, encoding: .utf8)!)
        }
        
        XCTAssertEqual(
            files,
            [
                FileContents(
                    destination: Destination(
                        directory: URL(string: "~/")!,
                        file: URL(string: "Font+extension.swift")!
                    ),
                    data: contents.data(using: .utf8)!
                )
            ]
        )
    }
    
    func testExportLabel() throws {
        let output = XcodeTypographyOutput(
            generateLabels:true,
            labelsDirectory: URL(string: "~/")!
        )
        let exporter = XcodeTypographyExporter(output: output)
        
        let styles = [
            makeTextStyle(name: "largeTitle", fontName: "PTSans-Bold", fontStyle: .largeTitle, fontSize: 34, lineHeight: nil),
            makeTextStyle(name: "header", fontName: "PTSans-Bold", fontSize: 20, lineHeight: nil),
            makeTextStyle(name: "body", fontName: "PTSans-Regular", fontStyle: .body, fontSize: 16, lineHeight: nil, letterSpacing: 1.2),
            makeTextStyle(name: "caption", fontName: "PTSans-Regular", fontStyle: .footnote, fontSize: 14, lineHeight: 20)
        ]
        let files = try exporter.export(textStyles: styles)
        
        let contentsLabel = """
        //
        //  The code generated using FigmaExport — Command line utility to export
        //  colors, typography, icons and images from Figma to Xcode project.
        //
        //  https://github.com/RedMadRobot/figma-export
        //
        //  Don’t edit this code manually to avoid runtime crashes
        //

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

        public final class LargeTitleLabel: Label {

            override var style: LabelStyle? {
                LabelStyle(
                    font: UIFont.largeTitle(),
                    fontMetrics: UIFontMetrics(forTextStyle: .largeTitle)
                )
            }
        }

        public final class HeaderLabel: Label {

            override var style: LabelStyle? {
                LabelStyle(
                    font: UIFont.header()
                )
            }
        }

        public final class BodyLabel: Label {

            override var style: LabelStyle? {
                LabelStyle(
                    font: UIFont.body(),
                    fontMetrics: UIFontMetrics(forTextStyle: .body),
                    tracking: 1.2
                )
            }
        }

        public final class CaptionLabel: Label {

            override var style: LabelStyle? {
                LabelStyle(
                    font: UIFont.caption(),
                    fontMetrics: UIFontMetrics(forTextStyle: .footnote),
                    lineHeight: 20.0
                )
            }
        }

        """
        
        let contentsLabelStyle = """
        //
        //  The code generated using FigmaExport — Command line utility to export
        //  colors, typography, icons and images from Figma to Xcode project.
        //
        //  https://github.com/RedMadRobot/figma-export
        //
        //  Don’t edit this code manually to avoid runtime crashes
        //

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
        
        XCTAssertEqual(files.count, 2, "Must be generated 2 files but generated \(files.count)")
        XCTAssertEqual(
            files,
            [
                FileContents(
                    destination: Destination(
                        directory: URL(string: "~/")!,
                        file: URL(string: "Label.swift")!
                    ),
                    data: contentsLabel.data(using: .utf8)!
                ),
                FileContents(
                    destination: Destination(
                        directory: URL(string: "~/")!,
                        file: URL(string: "LabelStyle.swift")!
                    ),
                    data: contentsLabelStyle.data(using: .utf8)!
                )
            ]
        )
    }
    
    private func makeTextStyle(
        name: String = "name",
        fontName: String = "fontName",
        fontStyle: DynamicTypeStyle? = nil,
        fontSize: Double,
        lineHeight: Double? = nil,
        letterSpacing: Double = 0) -> TextStyle {
        
        return TextStyle(
            name: name,
            fontName: fontName,
            fontSize: fontSize,
            fontStyle: fontStyle,
            lineHeight: lineHeight,
            letterSpacing: letterSpacing)
    }
}
