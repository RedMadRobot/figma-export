import Foundation

public typealias APIResult<Value> = Swift.Result<Value, Error>

final public class FigmaClient {

    private let baseURL = URL(string: "https://api.figma.com/v1/")!

    private let session: URLSession
    private let accessToken: String

    public init(accessToken: String) {
        let config = URLSessionConfiguration.ephemeral
        self.accessToken = accessToken

        config.timeoutIntervalForRequest = 30
        session = URLSession(configuration: config, delegate: nil, delegateQueue: .main)
    }

    public func request<T>(_ endpoint: T) throws -> T.Content where T: Endpoint {
        var outResult: APIResult<T.Content>!

        let task = request(endpoint, completion: { result in
            switch result {
            case .success:
                break

            case .failure(let error):
                print(error.localizedDescription)
            }
            outResult = result
        })
        task.wait()

        return try outResult.get()
    }

    public func request<T>(
        _ endpoint: T,
        completion: @escaping (APIResult<T.Content>) -> Void
    ) -> URLSessionTask where T: Endpoint {

        var request = endpoint.makeRequest(baseURL: baseURL)
        request.setValue(accessToken, forHTTPHeaderField: "X-Figma-Token")

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
        print("request url:", request.cURL())

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

extension URLRequest {
    public func cURL(pretty: Bool = false) -> String {
        let newLine = pretty ? "\\\n" : ""
        let method = (pretty ? "--request " : "-X ") + "\(self.httpMethod ?? "GET") \(newLine)"
        let url: String = (pretty ? "--url " : "") + "\'\(self.url?.absoluteString ?? "")\' \(newLine)"

        var cURL = "curl "
        var header = ""
        var data: String = ""

        if let httpHeaders = self.allHTTPHeaderFields, httpHeaders.keys.count > 0 {
            for (key,value) in httpHeaders {
                header += (pretty ? "--header " : "-H ") + "\'\(key): \(value)\' \(newLine)"
            }
        }

        if let bodyData = self.httpBody, let bodyString = String(data: bodyData, encoding: .utf8),  !bodyString.isEmpty {
            data = "--data '\(bodyString)'"
        }

        cURL += method + url + header + data

        return cURL
    }
}
