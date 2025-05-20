import Foundation

public struct FlutterIconsOutput {
    let iconsAssetsFolder: URL
    let outputFile: URL
    let iconsClassName: String
    let baseAssetClass: String
    let baseAssetClassFilePath: String
    let relativeIconsPath: URL
    let useSvgVec: Bool
    let templatesURL: URL?

    public init(
        iconsAssetsFolder: URL? = nil,
        outputFile: URL? = nil,
        iconsClassName: String? = nil,
        baseAssetClass: String? = nil,
        baseAssetClassFilePath: String? = nil,
        relativeIconsPath: URL,
        useSvgVec: Bool? = nil,
        templatesURL: URL? = nil
    ) {
        let currentDir = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        self.iconsAssetsFolder = iconsAssetsFolder ?? currentDir.appendingPathComponent("icons", isDirectory: true)
        self.outputFile = outputFile ?? currentDir.appendingPathComponent("icons.dart", isDirectory: false)
        self.iconsClassName = iconsClassName ?? "Icons"
        self.baseAssetClass = baseAssetClass ?? "IconAsset"
        self.baseAssetClassFilePath = baseAssetClassFilePath ?? "icon_asset.dart"
        self.relativeIconsPath = relativeIconsPath
        self.useSvgVec = useSvgVec ?? false
        self.templatesURL = templatesURL
    }
}
