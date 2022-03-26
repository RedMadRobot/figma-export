import Foundation
#if os(Linux)
import FoundationNetworking
#endif

public struct NodesEndpoint: BaseEndpoint {
    public typealias Content = [NodeId: Node]

    private let nodeIds: String
    private let fileId: String
    
    public init(fileId: String, nodeIds: [String]) {
        self.fileId = fileId
        self.nodeIds = nodeIds.joined(separator: ",")
    }

    func content(from root: NodesResponse) -> Content {
        return root.nodes
    }

    public func makeRequest(baseURL: URL) -> URLRequest {
        let url = baseURL
            .appendingPathComponent("files")
            .appendingPathComponent(fileId)
            .appendingPathComponent("nodes")
        
        var comps = URLComponents(url: url, resolvingAgainstBaseURL: true)
        comps?.queryItems = [
            URLQueryItem(name: "ids", value: nodeIds)
        ]
        return URLRequest(url: comps!.url!)
    }

}
