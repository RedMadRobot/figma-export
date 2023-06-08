import Foundation

public struct UIComponent: Asset {

    public var name: String

    public let platform: Platform?

    public let cornerRadius: Double

    public var cornerRadiusDimensionName: String {
        "\(name.snakeCased())_corner_radius"
    }

    public init(name: String, platform: Platform? = nil, cornerRadius: Double?) {
        self.name = name
        self.platform = platform
        self.cornerRadius = cornerRadius ?? .zero
    }

    // MARK: Hashable

    public static func == (lhs: UIComponent, rhs: UIComponent) -> Bool {
        return lhs.name == rhs.name
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }

}
