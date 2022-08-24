//
//  Version1.swift
//  
//
//  Created by Ivan Mikhailovskii on 24.08.2022.
//

import Foundation
import FigmaExportCore

extension XcodeTypographyExporter {

    struct Version1 {

        static func configureStyles(_ textStyles: [TextStyle], folderURL: URL) throws -> [FileContents] {
            return [
                try DefaultSQStyle.configure(folderURL: folderURL),
                try Version1SQFontStyle.configure(textStyles: textStyles, folderURL: folderURL),
                try Version1SQStyleLabel.configure(folderURL: folderURL),
                try Version1SQStyleButton.configure(folderURL: folderURL),
                try Version1SQStyleAttributedString.configure(folderURL: folderURL),
                try Version1SQStyleTextInput.configure(folderURL: folderURL)
            ]
        }

        static func configureComponents(_ textStyles: [TextStyle], folderURL: URL) throws -> [FileContents] {
            return [
                try DefaultSQLabel.configure(folderURL: folderURL),
                try DefaultSQButton.configure(folderURL: folderURL),
                try DefaultSQTextField.configure(folderURL: folderURL),
                try DefaultSQTextView.configure(folderURL: folderURL)
            ]
        }
    }
}
