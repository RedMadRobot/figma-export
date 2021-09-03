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

    public convenience init(text: String?, textColor: UIColor) {
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

            attributedText = style.attributedString(from: newText, alignment: textAlignment, lineBreakMode: lineBreakMode)
        }
    }
}

public final class BodyLabel: Label {

    override var style: LabelStyle? {
        .body()
    }
}

public final class CaptionLabel: Label {

    override var style: LabelStyle? {
        .caption()
    }
}

public final class HeaderLabel: Label {

    override var style: LabelStyle? {
        .header()
    }
}

public final class LargeTitleLabel: Label {

    override var style: LabelStyle? {
        .largeTitle()
    }
}

public final class UppercasedLabel: Label {

    override var style: LabelStyle? {
        .uppercased()
    }
}
