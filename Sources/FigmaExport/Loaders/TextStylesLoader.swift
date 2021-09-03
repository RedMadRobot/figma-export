import FigmaAPI
import FigmaExportCore

/// Loads text styles from Figma
final class TextStylesLoader {
    
    private let client: Client
    private let params: Params.Figma

    init(client: Client, params: Params.Figma) {
        self.client = client
        self.params = params
    }
    
    func load() throws -> [TextStyle] {
        return try loadTextStyles(fileId: params.lightFileId)
    }
    
    private func loadTextStyles(fileId: String) throws -> [TextStyle] {
        let styles = try loadStyles(fileId: fileId)

        guard !styles.isEmpty else {
            throw FigmaExportError.stylesNotFound
        }

        let nodes = try loadNodes(fileId: fileId, nodeIds: styles.map { $0.nodeId } )
        
        return styles.compactMap { style -> TextStyle? in
            guard let node = nodes[style.nodeId] else { return nil}
            guard let textStyle = node.document.style else { return nil }
            
            let lineHeight: Double? = textStyle.lineHeightUnit == .intrinsic ? nil : textStyle.lineHeightPx
            
            let textCase: TextStyle.TextCase
            switch textStyle.textCase {
            case .lower:
                textCase = .lowercased
            case .upper:
                textCase = .uppercased
            default:
                textCase = .original
            }
            
            return TextStyle(
                name: style.name,
                fontName: textStyle.fontPostScriptName,
                fontSize: textStyle.fontSize,
                fontStyle: DynamicTypeStyle(rawValue: style.description),
                lineHeight: lineHeight,
                letterSpacing: textStyle.letterSpacing
            )
        }
    }

    private func loadStyles(fileId: String) throws -> [Style] {
        let endpoint = StylesEndpoint(fileId: fileId)
        let styles = try client.request(endpoint)
        return styles.filter { $0.styleType == .text }
    }

    private func loadNodes(fileId: String, nodeIds: [String]) throws -> [NodeId: Node] {
        let endpoint = NodesEndpoint(fileId: fileId, nodeIds: nodeIds)
        return try client.request(endpoint)
    }
}
