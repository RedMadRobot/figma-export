import Foundation

struct FigmaClientError: Decodable, LocalizedError {
    let status: Int
    let err: String
    
    var errorDescription: String? {
        switch err {
        case "Not found":
            return "Figma file not found. Check lightFileId and darkFileId (if you project supports dark mode) in the yaml config file."
        default:
            return "Figma API: \(err)"
        }
    }
}

extension FigmaClientError: Equatable {
    
    static let notFound = FigmaClientError(
        status: 404,
        err: "Not found"
    )
}
