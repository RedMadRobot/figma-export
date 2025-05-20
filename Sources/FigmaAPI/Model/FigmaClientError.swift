import Foundation

struct FigmaClientError: Decodable, LocalizedError {
    let status: Int
    let err: String
    
    var errorDescription: String? {
        switch err {
        case "Not found":
            return "Figma file not found. Check lightFileId and darkFileId (if your project supports dark mode) in the yaml config file. Also verify that your personal access token is valid and hasn't expired."
        default:
            return "Figma API: \(err)"
        }
    }
}
