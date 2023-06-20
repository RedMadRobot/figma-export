import Foundation
import FigmaAPI
import FigmaExportCore

final class DimensionsLoader {

    let figmaClient: FigmaClient
    let params: Params

    init(figmaClient: FigmaClient, params: Params) {
        self.figmaClient = figmaClient
        self.params = params
    }

    func load(filter: String? = nil) throws -> [UIComponent] {
        let nodeIds = try self.loadComponentNodeIds()
        if nodeIds.isEmpty { return [] }

        let nodes = try self.loadNodes(nodeIds: nodeIds)
        return nodes.map { nodeId, node in

            var cornerRadius: Double?
            if node.document.type == .sectionNodeType,
               let firstChildrenNode = node.document.children?.first(
                where: { $0.type == .componentNodeType }
               ) {
                cornerRadius = firstChildrenNode.cornerRadius
            } else if node.document.type == .componentNodeType {
                cornerRadius = node.document.cornerRadius
            }

            return UIComponent(
                name: node.document.name,
                cornerRadius: cornerRadius
            )
        }

    }

    private func loadComponentNodeIds() throws -> [String] {
        let endpoint = ComponentsEndpoint(fileId: self.params.figma.lightFileId)
        let whiteList = self.params.common?.dimensions?.componentNames ?? []
        let result = try figmaClient.request(endpoint)
        let nodeIds = result.compactMap {
            if whiteList.contains($0.name.snakeCased()) {
                return $0.nodeId
            }

            if let frameName = $0.containingFrame.name,
               whiteList.contains(frameName.snakeCased()) {
                return $0.containingFrame.nodeId
            }

            return nil
        }
        return nodeIds.uniqued()
    }

    private func loadNodes(nodeIds: [String]) throws -> [NodeId: Node] {
        let endpoint = NodesEndpoint(fileId: self.params.figma.lightFileId, nodeIds: nodeIds)
        return try figmaClient.request(endpoint)
    }
}

private extension String {

    static let sectionNodeType = "SECTION"
    static let componentNodeType = "COMPONENT"
}
