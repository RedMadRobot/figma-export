import Foundation

public struct FlutterIconsOutput {
    let iconsAssetsFolder: URL
    let outputFile: URL
    let iconsClassName: String
    let baseAssetClass: String
    let baseAssetClassFilePath: String
    let useSvgVec: Bool
    let relativeIconsPath: URL
    let templatesURL: URL?

    public init(
        iconsAssetsFolder: URL? = nil,
        outputFile: URL? = nil,
        iconsClassName: String? = nil,
        baseAssetClass: String? = nil,
        baseAssetClassFilePath: String? = nil,
        useSvgVec: Bool? = nil,
        relativeIconsPath: URL,
        templatesURL: URL? = nil
    ) {
        let currentDir = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        self.iconsAssetsFolder = iconsAssetsFolder ?? currentDir.appendingPathComponent("icons", isDirectory: true)
        self.outputFile = outputFile ?? currentDir.appendingPathComponent("icons.dart", isDirectory: false)
        self.iconsClassName = iconsClassName ?? "Icons"
        self.baseAssetClass = baseAssetClass ?? "IconAsset"
        self.baseAssetClassFilePath = baseAssetClassFilePath ?? "icon_asset.dart"
        self.useSvgVec = useSvgVec ?? false
        self.relativeIconsPath = relativeIconsPath
        self.templatesURL = templatesURL
    }
}
