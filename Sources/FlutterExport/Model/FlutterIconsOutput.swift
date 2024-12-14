import Foundation

public struct FlutterIconsOutput {
    let iconsAssetsFolder: URL
    let classFile: URL
    let iconsClassName: String
    let relativeIconsPath: URL
    let templatesURL: URL?

    public init(
        iconsAssetsFolder: URL? = nil,
        classFile: URL? = nil,
        iconsClassName: String? = nil,
        relativeIconsPath: URL,
        templatesURL: URL? = nil
    ) {
        let currentDir = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        self.iconsAssetsFolder = iconsAssetsFolder ?? currentDir.appendingPathComponent("icons", isDirectory: true)
        self.classFile = classFile ?? currentDir.appendingPathComponent("icons.dart", isDirectory: false)
        self.iconsClassName = iconsClassName ?? "IconAssets"
        self.relativeIconsPath = relativeIconsPath
        self.templatesURL = templatesURL
    }
}
