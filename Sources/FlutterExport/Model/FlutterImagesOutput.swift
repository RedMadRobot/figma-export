import Foundation

public struct FlutterImagesOutput {
    public let imagesAssetsFolder: URL
    public let outputFile: URL
    public let imagesClassName: String
    public let baseAssetClass: String
    public let baseAssetClassFilePath: String
    public let relativeImagesPath: URL
    public let format: String
    public let scales: Set<Double>
    public let templatesURL: URL?

    public init(
        imagesAssetsFolder: URL? = nil,
        outputFile: URL? = nil,
        imagesClassName: String? = nil,
        baseAssetClass: String? = nil,
        baseAssetClassFilePath: String? = nil,
        relativeImagesPath: URL,
        format: String,
        scales: Set<Double>,
        templatesURL: URL? = nil
    ) {
        let currentDir = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        self.imagesAssetsFolder = imagesAssetsFolder ?? currentDir.appendingPathComponent("images", isDirectory: true)
        self.outputFile = outputFile ?? currentDir.appendingPathComponent("images.dart", isDirectory: false)
        self.imagesClassName = imagesClassName ?? "Images"
        self.baseAssetClass = baseAssetClass ?? "ImageAsset"
        self.baseAssetClassFilePath = baseAssetClassFilePath ?? "image_asset.dart"
        self.relativeImagesPath = relativeImagesPath
        self.format = format
        self.scales = scales
        self.templatesURL = templatesURL
    }
}
