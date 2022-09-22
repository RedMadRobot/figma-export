//
//  File.swift
//  
//
//  Created by Semen Kologrivov on 22.09.2022.
//

import Foundation
import FigmaExportCore

struct Version2SQFontStyle {

    static func configure(textStyles: [TextStyle], folderURL: URL) throws -> FileContents {
        let styles = textStyles.map {
            """
                static var \($0.name): SQFont {
                    .init(
                        name: "\($0.fontName)",
                        size: \($0.fontSize),
                        letterSpacing: \($0.letterSpacing),
                        lineHeight: \($0.lineHeight ?? $0.fontSize)
                    )
                }
            """
        }

        let content = """
        \(header)
        //
        //  NOTE: For using the typography styling, import our
        //  module with styled components:
        //
        //  https://gitlab.sequenia.com/ios-development/modules/uicomponents

        import UIKit
        import UIComponents

        extension SQFont {

        \(styles.joined(separator: "\n\n"))

        }
        """

        return try XcodeTypographyExporter.makeFileContents(
            data: content,
            directoryURL: folderURL,
            fileName: "SQFont+DefinedStyles.swift"
        )
    }
}

