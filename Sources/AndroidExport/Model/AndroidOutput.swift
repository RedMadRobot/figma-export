import Foundation

public struct AndroidOutput {
    let xmlOutputDirectory: URL
    let xmlResourcePackage: String?
    let composeOutputDirectory: URL?
    let packageName: String?

    public init(
        xmlOutputDirectory: URL,
        xmlResourcePackage: String?,
        srcDirectory: URL?,
        packageName: String?
    ) {
        self.xmlOutputDirectory = xmlOutputDirectory
        self.xmlResourcePackage = xmlResourcePackage
        self.packageName = packageName
        if let srcDirectory = srcDirectory, let packageName = packageName {
            composeOutputDirectory = srcDirectory.appendingPathComponent(packageName.replacingOccurrences(of: ".", with: "/"))
        } else {
            composeOutputDirectory = nil
        }
        
    }
}
