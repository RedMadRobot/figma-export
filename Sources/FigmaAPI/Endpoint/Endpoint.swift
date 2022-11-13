import Foundation
#if os(Linux)
import FoundationNetworking
#endif

/// The endpoint to work with a remote content.
public protocol Endpoint {

    /// Resource type.
    associatedtype Content

    /// Create a new `URLRequest`.
    ///
    /// - Returns: Resource request.
    /// - Throws: Any error creating request.
    func makeRequest(baseURL: URL) -> URLRequest

    /// Obtain new content from response with body.
    ///
    /// - Parameters:
    ///   - response: The metadata associated with the response.
    ///   - body: The response body.
    /// - Returns: A new endpoint content.
    /// - Throws: Any error creating content.
    func content(from response: URLResponse?, with body: Data) throws -> Content
}
