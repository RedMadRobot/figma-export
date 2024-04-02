public struct Mode: Decodable {
    public var modeId: String
    public var name: String
}

public struct VariableCollectionId: Decodable {
    public var name: String
    public var key: String
    public var remote: Bool
    public var defaultModeId: String
    public var modes: [Mode]
    public var id: String
    public var variableIds: [String]
    public var hiddenFromPublishing: Bool
}

public enum ResolvedType: String, Decodable {
    case boolean = "BOOLEAN"
    case float = "FLOAT"
    case string = "STRING"
    case color = "COLOR"
}

public struct VariableAlias: Codable {
    public var id: String
    public var type: String
}

public enum ValuesByMode: Decodable {
    case variableAlias(VariableAlias)
    case color(PaintColor)
    case string(String)
    case number(Double)
    case boolean(Bool)

    public enum CodingKeys: CodingKey {
        case variableAlias
        case color
        case string
        case number
        case boolean
    }

    public init(from decoder: Decoder) throws {
        if let variableAlias = try? VariableAlias(from: decoder) {
            self = .variableAlias(variableAlias)
        } else if let color = try? PaintColor(from: decoder) {
            self = .color(color)
        } else if let string = try? String(from: decoder) {
            self = .string(string)
        } else if let number = try? Double(from: decoder) {
            self = .number(number)
        } else if let boolean = try? Bool(from: decoder) {
            self = .boolean(boolean)
        } else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Data didn't match any expected type."))
        }
    }
}

public struct VariableID: Decodable {
    public var id: String
    public var name: String
    public var key: String
    public var variableCollectionId: String
    public var resolvedType: ResolvedType
    public var valuesByMode: [String: ValuesByMode]
    public var remote: Bool
    public var description: String
    public var hiddenFromPublishing: Bool
}

public struct VariablesMeta: Decodable {
    public var variableCollections: [String: VariableCollectionId]
    public var variables: [String: VariableID]
}

public struct VariablesResponse: Decodable {
    public let error: Bool
    public let status: Int
    public let meta: VariablesMeta
}
