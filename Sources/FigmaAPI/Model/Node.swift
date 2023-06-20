//
//  Node.swift
//  FigmaColorExporter
//
//  Created by Daniil Subbotin on 28.03.2020.
//  Copyright © 2020 Daniil Subbotin. All rights reserved.
//

public typealias NodeId = String

public struct NodesResponse: Decodable {
    public let nodes: [NodeId: Node]
}

public struct Node: Decodable {
    public let document: Document
}

public enum LineHeightUnit: String, Decodable {
    case pixels = "PIXELS"
    case fontSize = "FONT_SIZE_%"
    case intrinsic = "INTRINSIC_%"
}

public struct TypeStyle: Decodable {
    public var fontPostScriptName: String?
    public var fontWeight: Double
    public var fontSize: Double
    public var lineHeightPx: Double
    public var letterSpacing: Double
    public var lineHeightUnit: LineHeightUnit
}

public struct Document: Decodable {
    public let id: String
    public var name: String
    public let fills: [Paint]
    public let style: TypeStyle?
    public let type: String?
    public let cornerRadius: Double?
    public let children: [Document]?
}

public struct Paint: Decodable {
    public let type: String
    public let opacity: Double?
    public let color: PaintColor?
    public let gradientStops: [GradientStop]?
}

public struct PaintColor: Decodable {
    /// Channel value, between 0 and 1
    public let r, g, b, a: Double
}

public struct GradientStop: Decodable {
    public let color: PaintColor
    public let position: Int
}

extension Document {
    
    mutating func setName(_ name: String) {
        self.name = name
        print("name: \(name)")
    }
    
}
