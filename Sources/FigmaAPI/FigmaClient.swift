import Foundation

public typealias APIResult<Value> = Swift.Result<Value, Error>

final public class FigmaClient {
    
    private let baseURL = URL(string: "https://api.figma.com/v1/")!
    
    private let session: URLSession

    public init(accessToken: String, timeout: TimeInterval?) {
        let config = URLSessionConfiguration.ephemeral
        config.httpAdditionalHeaders = ["X-Figma-Token": accessToken]
        config.timeoutIntervalForRequest = timeout ?? 30
        session = URLSession(configuration: config, delegate: nil, delegateQueue: .main)
    }
    
    public func request<T>(_ endpoint: T) throws -> T.Content where T: Endpoint {
        var outResult: APIResult<T.Content>!
        
        let task = request(endpoint, completion: { result in
            outResult = result
        })
        task.wait()

        return try outResult.get()
    }
    
    public func request<T>(
        _ endpoint: T,
        completion: @escaping (APIResult<T.Content>) -> Void ) -> URLSessionTask where T: Endpoint {
        
        let request = endpoint.makeRequest(baseURL: baseURL)
        let task = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            
            guard let data = data, error == nil else {
                completion(.failure(error!))
                return
            }
            let content = APIResult<T.Content>(catching: { () -> T.Content in
                return try endpoint.content(from: response, with: data)
            })
            
            completion(content)
        }
        task.resume()
        return task
    }

}

internal extension URLSessionTask {

    /// Wait until task completed.
    func wait() {
        guard let timeout = currentRequest?.timeoutInterval else { return }
        let limitDate = Date(timeInterval: timeout, since: Date())
        while state == .running && RunLoop.current.run(mode: .default, before: limitDate) {
            // wait
        }
    }

}
