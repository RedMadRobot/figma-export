import FigmaAPI
import FigmaExportCore

/// Loads colors from Figma
final class ColorsLoader {
    
    typealias Output = (light: [Color], dark: [Color]?)
    
    private let figmaClient: FigmaClient
    private let params: Params.Figma

    init(figmaClient: FigmaClient, params: Params.Figma) {
        self.figmaClient = figmaClient
        self.params = params
    }
    
    func load() throws -> (light: [Color], dark: [Color]?) {
        let lightColors = try loadColors(fileId: params.lightFileId)
        let darkColors = try params.darkFileId.map { try loadColors(fileId: $0) }
        return (lightColors, darkColors)
    }
    
    private func loadColors(fileId: String) throws -> [Color] {
        let styles = try loadStyles(fileId: fileId)
        
        guard !styles.isEmpty else {
            throw FigmaExportError.stylesNotFound
        }
        
        let nodes = try loadNodes(fileId: fileId, nodeIds: styles.map { $0.nodeId } )
        return nodesAndStylesToColors(nodes: nodes, styles: styles)
    }
    
    /// Соотносит массив Style и Node чтобы получит массив Color
    private func nodesAndStylesToColors(nodes: [NodeId: Node], styles: [Style]) -> [Color] {
        return styles.compactMap { style -> Color? in
            guard let node = nodes[style.nodeId] else { return nil}
            guard let fill = node.document.fills.first else { return nil }
            let alpha: Double = fill.opacity ?? fill.color.a
            let platform = Platform(rawValue: style.description)
            
            return Color(name: style.name, platform: platform,
                         red: fill.color.r, green: fill.color.g, blue: fill.color.b, alpha: alpha)
        }
    }
    
    private func loadStyles(fileId: String) throws -> [Style] {
        let endpoint = StylesEndpoint(fileId: fileId)
        let styles = try figmaClient.request(endpoint)
        return styles.filter {
            $0.styleType == .fill && useStyle($0)
        }
    }
    
    private func useStyle(_ style: Style) -> Bool {
        guard !style.description.isEmpty else {
            return true // Цвет общий
        }
        return !style.description.contains("none")
    }
    
    private func loadNodes(fileId: String, nodeIds: [String]) throws -> [NodeId: Node] {
        let endpoint = NodesEndpoint(fileId: fileId, nodeIds: nodeIds)
        return try figmaClient.request(endpoint)
    }
}
