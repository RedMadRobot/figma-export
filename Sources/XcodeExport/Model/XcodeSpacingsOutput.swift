import Foundation

public struct XcodeSpacingsOutput {
    let spacingsUrl: URL?
    let addObjcAttribute: Bool
    let templatesPath: URL?

    public init(
        spacingsUrl: URL?,
        addObjcAttribute: Bool? = false,
        templatesPath: URL? = nil
    ) {
        self.spacingsUrl = spacingsUrl
        self.addObjcAttribute = addObjcAttribute ?? false
        self.templatesPath = templatesPath
    }
}
