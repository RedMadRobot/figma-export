//
//  File.swift
//  
//
//  Created by Semen Kologrivov on 19.01.2022.
//

import Foundation
import FigmaExportCore
import Stencil

extension XcodeTypographyExporter {

    func createSQStyleLabel(textStyles: [TextStyle], folderURL: URL) throws -> FileContents {
        let stringsLabel: [String] = textStyles.map {
            self.convertStyle(fromTextStyle: $0, type: .labelStyleName)
        }
        
        let content = """
        \(header)

        import UIKit

        class \(String.labelStyleName): SQStyle {

            \(stringsLabel.joined(separator: "\n\n"))

            \(self.alignments(forStyle: .labelStyleName))

            \(self.lineBreaks(forStyle: .labelStyleName))

            \(self.strikethroughTypes(forStyle: .labelStyleName))

            \(self.underlineTypes(forStyle: .labelStyleName))

            @objc lazy var textColor = { (color: UIColor?) -> \(String.labelStyleName) in
                self._textColor = color
                return self
            }

            func safeValue(forKey key: String) {
                let copy = Mirror(reflecting: self)
                for child in copy.children.makeIterator() {
                    if String(describing: child.label) == "Optional(\\"$__lazy_storage_$_\\(key)\\")" {
                        self.value(forKey: key)
                        return
                    }
                }
                fatalError("not font style: \\(key)")
            }
        }
        """

        return try self.makeFileContents(
            data: content,
            directoryURL: folderURL,
            fileName: "SQStyleLabel.swift"
        )
    }
}
