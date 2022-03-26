import Foundation
#if os(Linux)
import FoundationNetworking
#endif

final public class FigmaClient: BaseClient {
    
    private let baseURL = URL(string: "https://api.figma.com/v1/")!
    
    public init(accessToken: String, timeout: TimeInterval?) {
        let config = URLSessionConfiguration.ephemeral
        config.httpAdditionalHeaders = ["X-Figma-Token": accessToken]
        config.timeoutIntervalForRequest = timeout ?? 30
        super.init(baseURL: baseURL, config: config)
    }

}
