//
//  Version1SQStyleLabel.swift
//  
//
//  Created by Ivan Mikhailovskii on 24.08.2022.
//

import Foundation
import FigmaExportCore

struct Version1SQStyleLabel {

    static func configure(
        folderURL: URL
    ) throws -> FileContents {

        let content = """
        \(header)

        import UIKit

        class \(String.labelStyleName): SQStyle {

            @discardableResult
            func textColor(_ color: UIColor?) -> Self {
                self._textColor = color
                return self
            }
        }
        """

        return try XcodeTypographyExporter.makeFileContents(
            data: content,
            directoryURL: folderURL,
            fileName: String.labelStyleName + ".swift"
        )
    }
}
