import Foundation

public struct FlutterColorsOutput {
    public let generateVariationsAsProperties: Bool
    public let colorsClassName: String
    public let outputURL: URL
    public let templatesURL: URL?

    public init(
        generateVariationsAsProperties: Bool?,
        colorsClassName: String?,
        outputURL: URL,
        templatesURL: URL?
    ) {
        self.generateVariationsAsProperties = generateVariationsAsProperties ?? true
        self.colorsClassName = colorsClassName ?? "Colors"
        self.outputURL = outputURL
        self.templatesURL = templatesURL
    }
}
