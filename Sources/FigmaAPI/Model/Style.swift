public enum StyleType: String, Decodable {
    case fill = "FILL"
    case text = "TEXT"
    case effect = "EFFECT"
    case grid = "GRID"
}

public struct Style: Decodable {
    public let styleType: StyleType
    public let nodeId: String
    public let name: String
    public let description: String
    
    func getName() -> String {
        let components = self.name.components(separatedBy: "/")
        let name = "\(components.first?.lowerCamelCased() ?? "")"
        return name
    }
}

public struct StylesResponse: Decodable {
    public let error: Bool
    public let status: Int
    public let meta: StylesResponseContents
}

public struct StylesResponseContents: Decodable {
    public let styles: [Style]
}
