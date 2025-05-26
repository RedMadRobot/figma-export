import Foundation
#if os(Linux)
import FoundationNetworking
#endif

public struct VersionEndpoint: BaseEndpoint {
	public typealias Content = [Version]
	
	private let fileId: String
	
	public init(fileId: String) {
		self.fileId = fileId
	}
	
	func content(from root: VersionResponse) -> Content {
		root.versions
	}
	
	public func makeRequest(baseURL: URL) -> URLRequest {
		let url = baseURL
			.appendingPathComponent("files")
			.appendingPathComponent(fileId)
			.appendingPathComponent("versions")
		return URLRequest(url: url)
	}
}
