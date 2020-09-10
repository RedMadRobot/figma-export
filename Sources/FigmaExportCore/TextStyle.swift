public enum DynamicTypeStyle: String, RawRepresentable {
    case largeTitle = "Large Title"
    case title1 = "Title 1"
    case title2 = "Title 2"
    case title3 = "Title 3"
    case headline = "Headline"
    case body = "Body"
    case callout = "Callout"
    case subheadline = "Subhead"
    case footnote = "Footnote"
    case caption1 = "Caption 1"
    case caption2 = "Caption 2"
    
    public var textStyleName: String {
        switch self {
        case .largeTitle:
            return "largeTitle"
        case .title1:
            return "title1"
        case .title2:
            return "title2"
        case .title3:
            return "title3"
        case .headline:
            return "headline"
        case .body:
            return "body"
        case .callout:
            return "callout"
        case .subheadline:
            return "subheadline"
        case .footnote:
            return "footnote"
        case .caption1:
            return "caption1"
        case .caption2:
            return "caption2"
        }
    }
}

public struct TextStyle {
    
    public let name: String
    public let fontName: String
    public let fontSize: Double
    public let fontStyle: DynamicTypeStyle?
    public let lineHeight: Double?
    public let letterSpacing: Double

    public init(
        name: String,
        fontName: String,
        fontSize: Double,
        fontStyle: DynamicTypeStyle?,
        lineHeight: Double? = nil,
        letterSpacing: Double) {
        
        self.name = name
        self.fontName = fontName
        self.fontSize = fontSize
        self.fontStyle = fontStyle
        self.lineHeight = lineHeight
        self.letterSpacing = letterSpacing
    }
}
