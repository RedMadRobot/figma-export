//
//  The code generated using FigmaExport — Command line utility to export
//  colors, typography, icons and images from Figma to Xcode project.
//
//  https://github.com/RedMadRobot/figma-export
//
//  Don’t edit this code manually to avoid runtime crashes
//

import UIKit

public struct LabelStyle {

    enum TextCase {
        case uppercased
        case lowercased
        case original
    }

    let font: UIFont
    let fontMetrics: UIFontMetrics?
    let lineHeight: CGFloat?
    let tracking: CGFloat
    let textCase: TextCase
    
    init(font: UIFont, fontMetrics: UIFontMetrics? = nil, lineHeight: CGFloat? = nil, tracking: CGFloat = 0, textCase: TextCase = .original) {
        self.font = font
        self.fontMetrics = fontMetrics
        self.lineHeight = lineHeight
        self.tracking = tracking
        self.textCase = textCase
    }
    
    public func attributes(
        for alignment: NSTextAlignment = .left,
        lineBreakMode: NSLineBreakMode = .byTruncatingTail
    ) -> [NSAttributedString.Key: Any] {
        
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

    public func attributedString(
        from string: String,
        alignment: NSTextAlignment = .left,
        lineBreakMode: NSLineBreakMode = .byTruncatingTail
    ) -> NSAttributedString {
        let attributes = attributes(for: alignment, lineBreakMode: lineBreakMode)
        return NSAttributedString(string: convertText(string), attributes: attributes)
    }

    private func convertText(_ text: String) -> String {
        switch textCase {
        case .uppercased:
            return text.uppercased()
        case .lowercased:
            return text.lowercased()
        default:
            return text
        }
    }
}
