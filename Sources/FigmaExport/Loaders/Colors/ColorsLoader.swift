import FigmaAPI
import FigmaExportCore

typealias ColorsLoaderOutput = (light: [Color], dark: [Color]?, lightHC: [Color]?, darkHC: [Color]?)

/// Loads colors from Figma
final class ColorsLoader {

    private let client: Client
    private let figmaParams: Params.Figma
    private let colorParams: Params.Common.Colors?
    private let filter: String?

    init(
        client: Client,
        figmaParams: Params.Figma,
        colorParams: Params.Common.Colors?,
        filter: String?
    ) {
        self.client = client
        self.figmaParams = figmaParams
        self.colorParams = colorParams
        self.filter = filter
    }

    func load() throws -> ColorsLoaderOutput {
        guard let useSingleFile = colorParams?.useSingleFile, useSingleFile else {
            return try loadColorsFromLightAndDarkFile()
        }
        return try loadColorsFromSingleFile()
    }

    private func loadColorsFromLightAndDarkFile() throws -> ColorsLoaderOutput {
        let lightColors = try loadColors(fileId: figmaParams.lightFileId)
        let darkColors = try figmaParams.darkFileId.map { try loadColors(fileId: $0) }
        let lightHighContrastColors = try figmaParams.lightHighContrastFileId.map { try loadColors(fileId: $0) }
        let darkHighContrastColors = try figmaParams.darkHighContrastFileId.map { try loadColors(fileId: $0) }
        return (lightColors, darkColors, lightHighContrastColors, darkHighContrastColors)
    }

    private func loadColorsFromSingleFile() throws -> ColorsLoaderOutput {
        let colors = try loadColors(fileId: figmaParams.lightFileId)
        
        let darkSuffix = colorParams?.darkModeSuffix ?? "_dark"
        let lightHCSuffix = colorParams?.lightHCModeSuffix ?? "_lightHC"
        let darkHCSuffix = colorParams?.darkHCModeSuffix ?? "_darkHC"

        let lightColors = colors
            .filter {
                !$0.name.hasSuffix(darkSuffix) &&
                !$0.name.hasSuffix(lightHCSuffix) &&
                !$0.name.hasSuffix(darkHCSuffix)
            }
        let darkColors = filteredColors(colors, suffix: darkSuffix)
        let lightHCColors = filteredColors(colors, suffix: lightHCSuffix)
        let darkHCColors = filteredColors(colors, suffix: darkHCSuffix)
        return (lightColors, darkColors, lightHCColors, darkHCColors)
    }

    private func filteredColors(_ colors: [Color], suffix: String) -> [Color] {
        let filteredColors = colors
            .filter { $0.name.hasSuffix(suffix) }
            .map { color -> Color in
                var newColor = color
                newColor.name = String(color.name.dropLast(suffix.count))
                return newColor
            }
        return filteredColors
    }
    
    private func loadColors(fileId: String) throws -> [Color] {
        var styles = try loadStyles(fileId: fileId)
        
        if let filter {
            let assetsFilter = AssetsFilter(filter: filter)
            styles = styles.filter { style -> Bool in
                assetsFilter.match(name: style.name)
            }
        }
        
        guard !styles.isEmpty else {
            throw FigmaExportError.stylesNotFound
        }
        
        let nodes = try loadNodes(fileId: fileId, nodeIds: styles.map { $0.nodeId } )
        return nodesAndStylesToColors(nodes: nodes, styles: styles)
    }
    
    /// Соотносит массив Style и Node чтобы получит массив Color
    private func nodesAndStylesToColors(nodes: [NodeId: Node], styles: [Style]) -> [Color] {
        return styles.compactMap { style -> Color? in
            guard let node = nodes[style.nodeId] else { return nil }
            guard let fill = node.document.fills.first?.asSolid else { return nil }
            let alpha: Double = fill.opacity ?? fill.color.a
            let platform = Platform(rawValue: style.description)
            
            return Color(name: style.name, platform: platform,
                         red: fill.color.r, green: fill.color.g, blue: fill.color.b, alpha: alpha)
        }
    }
    
    private func loadStyles(fileId: String) throws -> [Style] {
        let endpoint = StylesEndpoint(fileId: fileId)
        let styles = try client.request(endpoint)
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
        return try client.request(endpoint)
    }
}
