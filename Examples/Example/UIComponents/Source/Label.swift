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
            lineHeight: 24.0
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
