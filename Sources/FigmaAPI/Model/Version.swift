import Foundation
#if os(Linux)
import FoundationNetworking
#endif

public struct Version: Codable {
	let id: String
	public let createdAt: Date?
	let label: String?
	let description: String?
}

public struct VersionResponse: Decodable {
	public var versions: [Version]
}
