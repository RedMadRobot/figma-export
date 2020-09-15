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
            print("Warning: Font \(name) not found.")
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