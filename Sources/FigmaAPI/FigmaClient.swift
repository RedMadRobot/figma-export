// ABOUTME: FigmaClient is the main API client for Figma REST API
// ABOUTME: Supports automatic retry with exponential backoff for rate limiting

import Foundation
#if os(Linux)
import FoundationNetworking
#endif

public enum FigmaAuth {
    case personalToken(String)
    case oauth(String)
}

final public class FigmaClient: BaseClient {

    private let baseURL = URL(string: "https://api.figma.com/v1/")!
    private let retryConfiguration: RetryConfiguration

    public init(
        auth: FigmaAuth,
        timeout: TimeInterval?,
        retryConfiguration: RetryConfiguration = .default,
        requestDelay: TimeInterval? = nil
    ) {
        // If requestDelay is explicitly provided, override the configuration value
        if let requestDelay = requestDelay {
            self.retryConfiguration = RetryConfiguration(
                maxRetries: retryConfiguration.maxRetries,
                maxRetryAfterSeconds: retryConfiguration.maxRetryAfterSeconds,
                initialBackoffSeconds: retryConfiguration.initialBackoffSeconds,
                backoffMultiplier: retryConfiguration.backoffMultiplier,
                requestDelaySeconds: requestDelay
            )
        } else {
            self.retryConfiguration = retryConfiguration
        }
        let config = URLSessionConfiguration.ephemeral
        switch auth {
        case .personalToken(let token):
            config.httpAdditionalHeaders = ["X-Figma-Token": token]
        case .oauth(let token):
            config.httpAdditionalHeaders = ["Authorization": "Bearer \(token)"]
        }
        config.timeoutIntervalForRequest = timeout ?? 30
        super.init(baseURL: baseURL, config: config)
    }

    /// Convenience method that uses the client's default retry configuration
    public func requestWithRetry<T>(_ endpoint: T) throws -> T.Content where T: Endpoint {
        return try requestWithRetry(endpoint, configuration: retryConfiguration)
    }

}
