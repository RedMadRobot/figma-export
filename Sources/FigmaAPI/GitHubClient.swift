import Foundation
#if os(Linux)
import FoundationNetworking
#endif

final public class GitHubClient: BaseClient {
    
    private let baseURL = URL(string: "https://api.github.com/")!
    
    public init() {
        let config = URLSessionConfiguration.ephemeral
        config.timeoutIntervalForRequest = 10
        super.init(baseURL: baseURL, config: config)
    }

}
