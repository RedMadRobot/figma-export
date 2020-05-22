import Foundation

struct FigmaClientError: Decodable, LocalizedError {
    let status: Int
    let err: String
    
    var errorDescription: String? { "Figma API: \(err)" }
}
