//
//  AndroidTypographyExporter.swift
//  
//
//  Created by Ivan Mikhailovskii on 12.12.2022.
//

import Foundation
import FigmaExportCore

final public class AndroidTypographyExporter {

    private let outputDirectory: URL
    private let attributes: [TypographyAttributes]?

    public init(
        outputDirectory: URL,
        attributes: [TypographyAttributes]?) {

        self.outputDirectory = outputDirectory
        self.attributes = attributes
    }

    public func makeTypographyFile(
        _ textStyles: [TextStyle],
        colorPairs: [AssetPair<Color>],
        dark: Bool
    ) -> FileContents {
        let contents = prepareTypographyDotXMLContents(
            textStyles,
            colorPairs: colorPairs,
            dark: dark
        )

        let directoryURL = outputDirectory.appendingPathComponent(dark ? "values-night" : "values")
        let fileURL = URL(string: "style_text.xml")!

        return FileContents(
            destination: Destination(directory: directoryURL, file: fileURL),
            data: contents
        )
    }

    private func prepareTypographyDotXMLContents(
        _ textStyles: [TextStyle],
        colorPairs: [AssetPair<Color>],
        dark: Bool
    ) -> Data {

        let resources = XMLElement(name: "resources")
        let xml = XMLDocument(rootElement: resources)
        var useFontNames = [""]

        let colors = colorPairs.filter { $0.light.name.contains("text") }

        textStyles.forEach { textStyle in
            let style = XMLElement(name: "style")
            let fontName = textStyle.fontName
            let fontNameResult = fontName.replacingOccurrences(of: "-", with: "_").lowercased()

            if !useFontNames.contains(textStyle.fontName) {

                style.addAttribute(XMLNode.attribute(withName: "name", stringValue: "\(fontNameResult.upperCamelCased())") as! XMLNode)
                let itemFontFamily = XMLElement(name: "item", stringValue: "@font/\(fontNameResult)")
                itemFontFamily.addAttribute(XMLNode.attribute(withName: "name", stringValue: "android:fontFamily") as! XMLNode)

                let itemTextStyle = XMLElement(name: "item", stringValue: "normal")
                itemTextStyle.addAttribute(XMLNode.attribute(withName: "name", stringValue: "android:textStyle") as! XMLNode)

                style.addChild(itemFontFamily)
                style.addChild(itemTextStyle)
                resources.addChild(style)

                useFontNames.append(textStyle.fontName)
            }

            let styleFont = XMLElement(name: "style")
            styleFont.addAttribute(XMLNode.attribute(withName: "name", stringValue: "\(textStyle.name.capitalized)") as! XMLNode)
            styleFont.addAttribute(XMLNode.attribute(withName: "parent", stringValue: "\(fontNameResult.upperCamelCased())") as! XMLNode)

            let itemTextSize = XMLElement(name: "item", stringValue: "\(textStyle.fontSize)sp")
            itemTextSize.addAttribute(XMLNode.attribute(withName: "name", stringValue: "android:textSize") as! XMLNode)

            let itemLineHeight = XMLElement(
                name: "item", stringValue: "\(textStyle.lineHeight ?? textStyle.fontSize)sp")
            itemLineHeight.addAttribute(XMLNode.attribute(withName: "name", stringValue: "lineHeight") as! XMLNode)

            let itemLetterSpacing = XMLElement(name: "item", stringValue: "\(textStyle.letterSpacing)")
            itemLetterSpacing.addAttribute(XMLNode.attribute(withName: "name", stringValue: "android:letterSpacing") as! XMLNode)

            styleFont.addChild(itemTextSize)
            styleFont.addChild(itemLineHeight)
            styleFont.addChild(itemLetterSpacing)

            if let attributes = self.attributes {
                attributes.forEach { attribute in
                    if attribute.fonts.first(where: { $0.lowercased() == textStyle.name.lowercased() }) != nil {
                        let itemAttribute = XMLElement(name: "item", stringValue: attribute.value)
                        itemAttribute.addAttribute(XMLNode.attribute(withName: "name", stringValue: attribute.name) as! XMLNode)

                        styleFont.addChild(itemAttribute)
                    }
                }
            }

            resources.addChild(styleFont)

            colors.forEach({ color in
                let styleColor = XMLElement(name: "style")
                styleColor.addAttribute(XMLNode.attribute(
                    withName: "name",
                    stringValue: "\(textStyle.name.capitalized).\(color.light.name.upperCamelCased())"
                ) as! XMLNode)

                let itemColor = XMLElement(name: "item", stringValue: "@color/\(color.light.name)")
                itemColor.addAttribute(XMLNode.attribute(withName: "name", stringValue: "android:textColor") as! XMLNode)

                styleColor.addChild(itemColor)
                resources.addChild(styleColor)
            })
        }

        return xml.xmlData(options: .nodePrettyPrint)
    }
}
