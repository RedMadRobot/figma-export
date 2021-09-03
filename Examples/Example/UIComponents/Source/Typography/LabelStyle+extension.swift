//
//  The code generated using FigmaExport — Command line utility to export
//  colors, typography, icons and images from Figma to Xcode project.
//
//  https://github.com/RedMadRobot/figma-export
//
//  Don’t edit this code manually to avoid runtime crashes
//

import UIKit

public extension LabelStyle {
    
    static func body() -> LabelStyle {
        LabelStyle(
            font: UIFont.body(),
            fontMetrics: UIFontMetrics(forTextStyle: .body),
            lineHeight: 24.0
        )
    }
    
    static func caption() -> LabelStyle {
        LabelStyle(
            font: UIFont.caption(),
            fontMetrics: UIFontMetrics(forTextStyle: .footnote),
            lineHeight: 20.0
        )
    }
    
    static func header() -> LabelStyle {
        LabelStyle(
            font: UIFont.header()
        )
    }
    
    static func largeTitle() -> LabelStyle {
        LabelStyle(
            font: UIFont.largeTitle(),
            fontMetrics: UIFontMetrics(forTextStyle: .largeTitle)
        )
    }
    
    static func uppercased() -> LabelStyle {
        LabelStyle(
            font: UIFont.uppercased(),
            lineHeight: 20.0,
            textCase: .uppercased
        )
    }
    
}