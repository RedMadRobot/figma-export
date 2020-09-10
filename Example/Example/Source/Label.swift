import UIKit

class Label: UILabel {

    var style: LabelStyle? { nil }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
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

    override var text: String? {
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

final class LargeTitleLabel: Label {

    override var style: LabelStyle? {
        LabelStyle(
            font: UIFont.largeTitle(),
            fontMetrics: UIFontMetrics(forTextStyle: .largeTitle)
        )
    }
}

final class HeaderLabel: Label {

    override var style: LabelStyle? {
        LabelStyle(
            font: UIFont.header()
        )
    }
}

final class BodyLabel: Label {

    override var style: LabelStyle? {
        LabelStyle(
            font: UIFont.body(),
            fontMetrics: UIFontMetrics(forTextStyle: .body),
            lineHeight: 24.0
        )
    }
}

final class CaptionLabel: Label {

    override var style: LabelStyle? {
        LabelStyle(
            font: UIFont.caption(),
            fontMetrics: UIFontMetrics(forTextStyle: .footnote),
            lineHeight: 20.0
        )
    }
}
