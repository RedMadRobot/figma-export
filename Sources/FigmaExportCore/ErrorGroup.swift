import Foundation

public struct ErrorGroup: LocalizedError {

    public var all: [Error] = []
    public var errorDescription: String? {
        all.compactMap {
            ($0 as? LocalizedError)?.errorDescription ?? $0.localizedDescription
        }.joined(separator: "\n")
    }
    
    public init(all: [Error] = []) {
        self.all = all
    }
}
