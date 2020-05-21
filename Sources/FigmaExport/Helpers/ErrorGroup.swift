import Foundation

struct ErrorGroup: LocalizedError {
    var all: [Error] = []
    var errorDescription: String? {
        all.compactMap {
            ($0 as? LocalizedError)?.errorDescription ?? $0.localizedDescription
        }.joined(separator: "\n")
    }
}
