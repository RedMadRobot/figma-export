import Foundation

public struct AssetsFilter {
    
    private let filters: [String]
    
    public init(filter: String) {
        filters = filter
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
    }
    
    public init(filters: [String]) {
        self.filters = filters
    }
    
    /// Returns true if name matches with filter
    /// - Parameters:
    ///   - name: Name of the asset
    ///   - filter: Name of the assets separated by comma
    public func match(name: String) -> Bool {
        return filters.contains(where: { filter -> Bool in
            if filter.contains("*") {
                return wildcard(name, pattern: filter)
            } else {
                return name == filter
            }
        })
    }
    
    private func wildcard(_ string: String, pattern: String) -> Bool {
        #if os(Linux)
        return false
        #else
        let pred = NSPredicate(format: "self LIKE %@", pattern)
        return !NSArray(object: string).filtered(using: pred).isEmpty
        #endif
    }
}
