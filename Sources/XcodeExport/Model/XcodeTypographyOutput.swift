//
//  XcodeTypographyOutput.swift
//  
//
//  Created by Simon Lee on 3/26/21.
//

import Foundation

public struct XcodeTypographyOutput {

    let fontExtensionURL: URL?
    let swiftUIFontExtensionURL: URL?
    let generateLabels: Bool
    let labelsDirectory: URL?
    let addObjcAttribute: Bool

    public init(
        fontExtensionURL: URL? = nil,
        swiftUIFontExtensionURL: URL? = nil,
        generateLabels: Bool? = false,
        labelsDirectory: URL? = nil,
        addObjcAttribute: Bool? = false
    ) {
        self.fontExtensionURL = fontExtensionURL
        self.swiftUIFontExtensionURL = swiftUIFontExtensionURL
        self.generateLabels = generateLabels ?? false
        self.labelsDirectory = labelsDirectory
        self.addObjcAttribute = addObjcAttribute ?? false
    }
}
