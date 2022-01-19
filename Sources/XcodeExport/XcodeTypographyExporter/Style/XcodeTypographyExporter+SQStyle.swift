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

    func createSQStyle(folderURL: URL) throws -> FileContents {

        let content = """
        \(header)
        
        import UIKit

        protocol Style {

            func build()
        }

        protocol UIStyle: Style {

            associatedtype Element

            var style: Element { get }

            func resetStyle()
        }

        class SQStyle: NSObject {

            var element: Style!
            var font: UIFont?

            var lineHeight: CGFloat?
            var letterSpacing: CGFloat?

            var strikethroughStyle: NSUnderlineStyle?
            var underlineStyle: NSUnderlineStyle?

            init(element: Style) {
                self.element = element
            }

            func build() {
                self.element.build()
            }

            func customFont(
                _ name: String,
                size: CGFloat
            ) -> UIFont {

                guard let font = UIFont(name: name, size: size) else {
                    return UIFont.systemFont(ofSize: size, weight: .regular)
                }

                return font
            }

        }
        """

        return try self.makeFileContents(
            data: content,
            directoryURL: folderURL,
            fileName: "SQStyle.swift"
        )
    }
}
