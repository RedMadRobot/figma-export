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
    private let colorsMatchRegexp: String?
    private let strongMatchWithColors: Bool
    private let attributes: [TypographyAttributes]?

    public init(
        outputDirectory: URL,
        colorsMatchRegexp: String?,
        strongMatchWithColors: Bool?,
        attributes: [TypographyAttributes]?) {

            self.outputDirectory = outputDirectory
            self.colorsMatchRegexp = colorsMatchRegexp
            self.strongMatchWithColors = strongMatchWithColors ?? false
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

        let colors: [AssetPair<Color>]
        if let regexp = self.colorsMatchRegexp {
            colors = colorPairs.filter { $0.light.name.range(of: regexp, options: .regularExpression) != nil }
        } else {
            colors = colorPairs
        }

        textStyles.forEach { textStyle in
            if useFontNames.contains(textStyle.fontName) { return }

            let style = XMLElement(name: "style")
            let fontName = textStyle.fontName
            let fontStyleName = fontName.replacingOccurrences(of: "-", with: "_").upperCamelCased()
            let fontFileName = fontStyleName.lowercased()

            style.addAttribute(XMLNode.attribute(withName: "name", stringValue: "\(fontStyleName)") as! XMLNode)
            let itemFontFamily = XMLElement(name: "item", stringValue: "@font/\(fontFileName)")
            itemFontFamily.addAttribute(XMLNode.attribute(withName: "name", stringValue: "android:fontFamily") as! XMLNode)

            let itemTextStyle = XMLElement(name: "item", stringValue: "normal")
            itemTextStyle.addAttribute(XMLNode.attribute(withName: "name", stringValue: "android:textStyle") as! XMLNode)

            style.addChild(itemFontFamily)
            style.addChild(itemTextStyle)
            resources.addChild(style)

            useFontNames.append(textStyle.fontName)
        }

        textStyles
            .sorted(by: { $0.name < $1.name })
            .forEach { textStyle in
                let fontName = textStyle.fontName
                let fontStyleName = fontName.replacingOccurrences(of: "-", with: "_").upperCamelCased()

                let styleFont = XMLElement(name: "style")
                styleFont.addAttribute(XMLNode.attribute(withName: "name", stringValue: "\(textStyle.name.upperCamelCased())") as! XMLNode)
                styleFont.addAttribute(XMLNode.attribute(withName: "parent", stringValue: "\(fontStyleName)") as! XMLNode)

                let itemTextSize = XMLElement(name: "item", stringValue: "\(textStyle.fontSize)sp")
                itemTextSize.addAttribute(XMLNode.attribute(withName: "name", stringValue: "android:textSize") as! XMLNode)

                let itemLineHeight = XMLElement(
                    name: "item", stringValue: "\(textStyle.lineHeight ?? textStyle.fontSize)sp")
                itemLineHeight.addAttribute(XMLNode.attribute(withName: "name", stringValue: "lineHeight") as! XMLNode)

                let itemLetterSpacing = XMLElement(name: "item", stringValue: "\(textStyle.letterSpacing/textStyle.fontSize)")
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

                let workingColors = self.strongMatchWithColors ?
                colors.filter {
                    let colorName = $0.light.name.lowerCamelCased().lowercased()
                    let textStyleName = textStyle.name.lowerCamelCased().lowercased()
                    return colorName.starts(with: textStyleName)
                } :
                colors

                workingColors.forEach({ color in
                    let styleColor = XMLElement(name: "style")
                    let textStyleName = textStyle.name.upperCamelCased()
                    var colorStyleName = color.light.name.upperCamelCased()
                    if self.strongMatchWithColors {
                        colorStyleName = colorStyleName.replacingOccurrences(
                            of: textStyleName,
                            with: ""
                        )
                    }
                    styleColor.addAttribute(XMLNode.attribute(
                        withName: "name",
                        stringValue: "\(textStyleName).\(colorStyleName)"
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
