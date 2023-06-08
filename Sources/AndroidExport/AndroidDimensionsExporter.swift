//
//  AndroidTypographyExporter.swift
//
//
//  Created by Ivan Mikhailovskii on 12.12.2022.
//

import Foundation
import FigmaExportCore

final public class AndroidDimensionsExporter {

    private let outputDirectory: URL

    public init(
        outputDirectory: URL
    ) {

        self.outputDirectory = outputDirectory
    }

    public func makeDimensionsFile(
        _ components: [UIComponent]
    ) -> FileContents {
        let contents = prepareDimensionsDotXMLContents(components)

        let directoryURL = outputDirectory
        let fileURL = URL(string: "dimens.xml")!

        return FileContents(
            destination: Destination(directory: directoryURL, file: fileURL),
            data: contents
        )
    }

    private func prepareDimensionsDotXMLContents(
        _ components: [UIComponent]
    ) -> Data {

        let resources = XMLElement(name: "resources")
        let xml = XMLDocument(rootElement: resources)
        xml.version = "1.0"
        xml.characterEncoding = "utf-8"

        components
            .sorted(by: { $0.name < $1.name })
            .forEach { component in
                let formatter = NumberFormatter()
                formatter.maximumFractionDigits = .zero
                formatter.minimumFractionDigits = .zero
                formatter.numberStyle = .none
                formatter.alwaysShowsDecimalSeparator = false
                guard let formattedRadius = formatter.string(
                    from: component.cornerRadius as NSNumber
                ) else { return }

                let dimen = XMLElement(
                    name: "dimen",
                    stringValue: "\(formattedRadius)dp"
                )

                dimen.addAttribute(XMLNode.attribute(withName: "name", stringValue: "\(component.cornerRadiusDimensionName)") as! XMLNode)
                resources.addChild(dimen)
            }
        return xml.xmlData(options: .nodePrettyPrint)
    }
}
