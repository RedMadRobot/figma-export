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

public struct Document: Decodable {
    public let id: String
    public let name: String
    public let fills: [Paint]
}

public struct Paint: Decodable {
    public let type: String
    public let opacity: Double?
    public let color: PaintColor
}

public struct PaintColor: Decodable {
    /// Channel value, between 0 and 1
    public let r, g, b, a: Double
}
