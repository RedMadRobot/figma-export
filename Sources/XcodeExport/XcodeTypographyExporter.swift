import Foundation
import FigmaExportCore
import Stencil

final public class XcodeTypographyExporter: XcodeExporterBase {
    private let output: XcodeTypographyOutput

    public init(output: XcodeTypographyOutput) {
        self.output = output
    }

    public func export(textStyles: [TextStyle]) throws -> [FileContents] {
        var files: [FileContents] = []

        // UIKit UIFont extension
        if let fontExtensionURL = output.urls.fonts.fontExtensionURL {
            files.append(contentsOf: try exportFonts(
                textStyles: textStyles,
                fontExtensionURL: fontExtensionURL
            ))
        }

        // SwiftUI Font extension
        if let swiftUIFontExtensionURL = output.urls.fonts.swiftUIFontExtensionURL {
            files.append(contentsOf: try exportFonts(
                textStyles: textStyles,
                swiftUIFontExtensionURL: swiftUIFontExtensionURL
            ))
        }

        // UIKit Labels
        if output.generateLabels, let labelsDirectory = output.urls.labels.labelsDirectory  {
            // Label.swift
            // LabelStyle.swift
            files.append(contentsOf: try exportLabels(
                textStyles: textStyles,
                labelsDirectory: labelsDirectory,
                separateStyles: output.urls.labels.labelStyleExtensionsURL != nil
            ))
            
            // LabelStyle extensions
            if let labelStyleExtensionsURL = output.urls.labels.labelStyleExtensionsURL {
                files.append(contentsOf: try exportLabelStylesExtensions(
                    textStyles: textStyles,
                    labelStyleExtensionURL: labelStyleExtensionsURL
                ))
            }
        }

        return files
    }
    
    private func exportFonts(textStyles: [TextStyle], fontExtensionURL: URL) throws -> [FileContents] {
        let textStyles: [[String: Any]] = textStyles.map {
            [
                "name": $0.name,
                "fontName": $0.fontName,
                "fontSize": $0.fontSize,
                "supportsDynamicType": $0.fontStyle != nil,
                "type": $0.fontStyle?.textStyleName ?? ""
            ]
        }
        let env = makeEnvironment(templatesPath: output.templatesPath, trimBehavior: .none)
        let contents = try env.renderTemplate(name: "UIFont+extension.swift.stencil", context: [
            "textStyles": textStyles,
            "addObjcPrefix": output.addObjcAttribute
        ])
        return [try makeFileContents(for: contents, url: fontExtensionURL)]
    }
    
    private func exportFonts(textStyles: [TextStyle], swiftUIFontExtensionURL: URL) throws -> [FileContents] {
        let textStyles: [[String: Any]] = textStyles.map {
            [
                "name": $0.name,
                "fontName": $0.fontName,
                "fontSize": $0.fontSize,
                "supportsDynamicType": $0.fontStyle != nil,
                "type": $0.fontStyle?.textStyleName ?? ""
            ]
        }
        let env = makeEnvironment(templatesPath: output.templatesPath, trimBehavior: .none)
        let contents = try env.renderTemplate(name: "Font+extension.swift.stencil", context: [
            "textStyles": textStyles,
        ])
        return [try makeFileContents(for: contents, url: swiftUIFontExtensionURL)]
    }
    
    private func exportLabelStylesExtensions(textStyles: [TextStyle], labelStyleExtensionURL: URL) throws -> [FileContents] {
        let dict = textStyles.map { style -> [String: Any] in
            let type: String = style.fontStyle?.textStyleName ?? ""
            return [
                "className": style.name.first!.uppercased() + style.name.dropFirst(),
                "varName": style.name,
                "size": style.fontSize,
                "supportsDynamicType": style.fontStyle != nil,
                "type": type,
                "tracking": style.letterSpacing.floatingPointFixed,
                "lineHeight": style.lineHeight ?? 0,
                "textCase": style.textCase.rawValue
            ]}
        let env = makeEnvironment(templatesPath: output.templatesPath, trimBehavior: .none)
        let contents = try env.renderTemplate(name: "LabelStyle+extension.swift.stencil", context: ["styles": dict])
        
        let labelStylesSwiftExtension = try makeFileContents(for: contents, url: labelStyleExtensionURL)
        return [labelStylesSwiftExtension]
    }
    
    private func exportLabels(textStyles: [TextStyle], labelsDirectory: URL, separateStyles: Bool) throws -> [FileContents] {
        let dict = textStyles.map { style -> [String: Any] in
            let type: String = style.fontStyle?.textStyleName ?? ""
            return [
                "className": style.name.first!.uppercased() + style.name.dropFirst(),
                "varName": style.name,
                "size": style.fontSize,
                "supportsDynamicType": style.fontStyle != nil,
                "type": type,
                "tracking": style.letterSpacing.floatingPointFixed,
                "lineHeight": style.lineHeight ?? 0,
                "textCase": style.textCase.rawValue
            ]}
        let env = makeEnvironment(templatesPath: output.templatesPath, trimBehavior: .none)
        let contents = try env.renderTemplate(name: "Label.swift.stencil", context: [
            "styles": dict,
            "separateStyles": separateStyles
        ])
        let labelSwift = try makeFileContents(for: contents, directory: labelsDirectory, file: URL(string: "Label.swift")!)
        
        let labelStyleSwiftContents = try env.renderTemplate(name: "LabelStyle.swift.stencil")
        let labelStyleSwift = try makeFileContents(for: labelStyleSwiftContents, directory: labelsDirectory, file: URL(string: "LabelStyle.swift")!)

        return [labelSwift, labelStyleSwift]
    }
}
