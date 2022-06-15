import Foundation

public struct Spacing: Asset {

    public var name: String
    public var platform: Platform?
    public let size: Double

    public init(
            name: String,
            platform: Platform? = nil,
            size: Double
    ) {

        self.name = name
        self.platform = platform
        self.size = size
    }
    
    // MARK: Hashable

    public static func == (lhs: Spacing, rhs: Spacing) -> Bool {
        return lhs.name == rhs.name
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
}
