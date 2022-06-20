import FigmaAPI
import FigmaExportCore

/// Loads text styles from Figma
final class TextStylesLoader {
    
    private let client: Client
    private let params: Params.Figma
    private let typoParams: Params.Common.Typography?

    init(client: Client, params: Params.Figma, typoParams: Params.Common.Typography?) {
        self.client = client
        self.params = params
        self.typoParams = typoParams
    }
    
    func load() throws -> [TextStyle] {
        return try loadTextStyles(
            fileId: params.lightFileId,
            ignoreFolder: typoParams?.ignoreFolder ?? false,
            ignoreRegex: typoParams?.nameIgnoreExpression)
    }
    
    private func loadTextStyles(fileId: String, ignoreFolder: Bool, ignoreRegex: String?) throws -> [TextStyle] {
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

            var name = style.name

            if name.isEmpty == false {
                name = name.replacingOccurrences(of: ignoreRegex ?? "",
                                                 with: "",
                                                 options: .regularExpression)
                if ignoreFolder {
                    name = String(name.split(separator: "/").last!)
                }
            }

            return TextStyle(
                name: name,
                fontName: textStyle.fontPostScriptName ?? textStyle.fontFamily ?? "",
                fontSize: textStyle.fontSize,
                fontStyle: DynamicTypeStyle(rawValue: style.description),
                lineHeight: lineHeight,
                letterSpacing: textStyle.letterSpacing,
                textCase: textCase
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
