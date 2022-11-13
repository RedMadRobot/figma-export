import Foundation
#if os(Linux)
import FoundationNetworking
#endif

public struct StylesEndpoint: BaseEndpoint {
    public typealias Content = [Style]

    private let fileId: String
    
    public init(fileId: String) {
        self.fileId = fileId
    }

    func content(from root: StylesResponse) -> Content {
        return root.meta.styles
    }

    public func makeRequest(baseURL: URL) -> URLRequest {
        let url = baseURL
            .appendingPathComponent("files")
            .appendingPathComponent(fileId)
            .appendingPathComponent("styles")
        return URLRequest(url: url)
    }
    
}
