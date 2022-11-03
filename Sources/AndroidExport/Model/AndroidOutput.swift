import Foundation

public struct AndroidOutput {
    let xmlOutputDirectory: URL
    let xmlResourcePackage: String?
    let composeOutputDirectory: URL?
    let packageName: String?
    let templatesPath: URL?

    public init(
        xmlOutputDirectory: URL,
        xmlResourcePackage: String?,
        srcDirectory: URL?,
        packageName: String?,
        templatesPath: URL?
    ) {
        self.xmlOutputDirectory = xmlOutputDirectory
        self.xmlResourcePackage = xmlResourcePackage
        self.packageName = packageName
        self.templatesPath = templatesPath
        if let srcDirectory, let packageName {
            composeOutputDirectory = srcDirectory.appendingPathComponent(packageName.replacingOccurrences(of: ".", with: "/"))
        } else {
            composeOutputDirectory = nil
        }
    }
}
