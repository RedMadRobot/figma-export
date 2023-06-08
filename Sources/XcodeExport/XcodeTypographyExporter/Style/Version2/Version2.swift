//
//  File.swift
//  
//
//  Created by Semen Kologrivov on 22.09.2022.
//

import Foundation
import FigmaExportCore

extension XcodeTypographyExporter {

    struct Version2 {

        static func configureStyles(
            _ textStyles: [TextStyle],
            folderURL: URL,
            fileName: String?,
            format: Format?
        ) throws -> [FileContents] {
            return [
                try Version2SQFontStyle.configure(
                    textStyles: textStyles,
                    folderURL: folderURL,
                    fileName: fileName,
                    format: .init(rawValue: format?.rawValue ?? "")
                )
            ]
        }
    }
}
