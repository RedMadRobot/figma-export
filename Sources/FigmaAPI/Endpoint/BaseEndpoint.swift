import Foundation

/// Base Endpoint for application remote resource.
///
/// Contains shared logic for all endpoints in app.
protocol BaseEndpoint: Endpoint where Content: Decodable {
    /// Content wrapper.
    associatedtype Root: Decodable = Content

    /// Extract content from root.
    func content(from root: Root) -> Content
}

extension BaseEndpoint where Root == Content {
    func content(from root: Root) -> Content { return root }
}

extension BaseEndpoint {

    public func content(from response: URLResponse?, with body: Data) throws -> Content {
        do { 
            let resource = try JSONDecoder.default.decode(Root.self, from: body)
            return content(from: resource)
        } catch let mainError {
            self.logError(data: body, key: (mainError as! DecodingError).errorKey)
            
            if let error = try? JSONDecoder.default.decode(FigmaClientError.self, from: body) {
                throw error
            }
            throw mainError
        }
    }
    
    private func logError(data: Data, key: String) {
        if let jsonArray = try? JSONSerialization.jsonObject(with: data, options : .allowFragments) as? [String: Any] {
            
            if let nameNode = (((jsonArray["nodes"] as? [String: Any])?[key] as? [String: Any])?["document"] as? [String: Any])?["name"] {
            
                print("Name node: \(nameNode)")
            }
        }
    }
}

extension JSONDecoder {
    internal static let `default`: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
}

extension DecodingError: CustomNSError {

    public static var errorDomain: String {
        return "com.domain.App.ErrorDomain.DecodingError"
    }

    public var errorCode: Int {
        switch self {
        case .dataCorrupted:
            return 1
        case .keyNotFound:
            return 2
        case .typeMismatch:
            return 3
        case .valueNotFound:
            return 4
        default:
            return 5
        }
    }

    public var errorKey: String {
        switch self {
        case .keyNotFound(_, let context):
            return context.codingPath[1].stringValue
        default:
            return ""
        }
    }
}
