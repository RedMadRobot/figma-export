import Foundation

public struct XcodeTypographyOutput {
    
    let urls: URLS
    let generateLabels: Bool
    let addObjcAttribute: Bool
    
    public struct URLS {
        let fontExtensionURL: URL?
        let swiftUIFontExtensionURL: URL?
        let labelsDirectory: URL?
        let labelStyleExtensionsURL: URL?
        
        public init(
            fontExtensionURL: URL? = nil,
            swiftUIFontExtensionURL: URL? = nil,
            labelsDirectory: URL? = nil,
            labelStyleExtensionsURL: URL? = nil
        ) {
            self.labelsDirectory = labelsDirectory
            self.fontExtensionURL = fontExtensionURL
            self.swiftUIFontExtensionURL = swiftUIFontExtensionURL
            self.labelStyleExtensionsURL = labelStyleExtensionsURL
        }
    }

    public init(
        urls: URLS,
        generateLabels: Bool? = false,
        addObjcAttribute: Bool? = false
    ) {
        self.urls = urls
        self.generateLabels = generateLabels ?? false
        self.addObjcAttribute = addObjcAttribute ?? false
    }
}
