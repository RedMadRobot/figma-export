import Foundation
#if os(Linux)
import FoundationNetworking
#endif

public struct LatestReleaseEndpoint: BaseEndpoint {
    
    public typealias Content = LatestReleaseResponse

    public init() {}
    
    public func makeRequest(baseURL: URL) -> URLRequest {
        let url = baseURL.appendingPathComponent("repos/RedMadRobot/figma-export/releases/latest")
        return URLRequest(url: url)
    }
}

// MARK: - Response

public struct LatestReleaseResponse: Decodable {
    public let tagName: String
}

