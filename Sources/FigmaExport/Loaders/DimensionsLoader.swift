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

        return try self.loadNodes(nodeIds: nodeIds).map { nodeId, node in
            UIComponent(
                name: node.document.name,
                cornerRadius: node.document.cornerRadius
            )
        }

    }

    private func loadComponentNodeIds() throws -> [String] {
        let endpoint = ComponentsEndpoint(fileId: self.params.figma.lightFileId)
        let whiteList = self.params.common?.dimensions?.componentNames ?? []
        return try figmaClient.request(endpoint)
            .filter {
                let componentName = ($0.containingFrame.containingStateGroup?.name ?? $0.name).snakeCased()
                return whiteList.contains(componentName)
            }
            .map {
                $0.containingFrame.containingStateGroup?.nodeId ?? $0.nodeId
            }
            .uniqued()
    }

    private func loadNodes(nodeIds: [String]) throws -> [NodeId: Node] {
        let endpoint = NodesEndpoint(fileId: self.params.figma.lightFileId, nodeIds: nodeIds)
        return try figmaClient.request(endpoint)
    }
}
