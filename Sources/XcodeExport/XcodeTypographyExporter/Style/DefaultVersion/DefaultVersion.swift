//
//  File.swift
//  
//
//  Created by Ivan Mikhailovskii on 23.08.2022.
//

import Foundation
import FigmaExportCore

extension XcodeTypographyExporter {

    struct DefaultVersion {

        static func configureStyles(_ textStyles: [TextStyle], folderURL: URL) throws -> [FileContents] {
            return [
                try DefaultSQStyle.configure(folderURL: folderURL),
                try DefaultSQStyleLabel.configure(textStyles: textStyles, folderURL: folderURL),
                try DefaultSQStyleButton.configure(textStyles: textStyles, folderURL: folderURL),
                try DefaultSQStyleAttributedString.configure(textStyles: textStyles, folderURL: folderURL),
                try DefaultSQStyleTextInput.configure(textStyles: textStyles, folderURL: folderURL)
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
