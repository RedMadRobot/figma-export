import Foundation

public struct Destination {
    
    public let directory: URL
    public let file: URL
    
    public var url: URL {
        directory.appendingPathComponent(file.path)
    }
    
    public init(directory: URL, file: URL) {
        self.directory = directory
        self.file = file
    }
}

public struct FileContents {
    
    /// Where to save file?
    public let destination: Destination
    
    /// Raw data (in-memory)
    public let data: Data?
    
    /// Raw data (on-disk)
    public let dataFile: URL?
    
    /// Where to fetch data?
    public let sourceURL: URL?
    
    public var dark: Bool = false
    
    /// In-memory file
    public init(destination: Destination, data: Data) {
        self.destination = destination
        self.data = data
        self.dataFile = nil
        self.sourceURL = nil
    }
    
    /// Remote file
    public init(destination: Destination, sourceURL: URL) {
        self.destination = destination
        self.data = nil
        self.dataFile = nil
        self.sourceURL = sourceURL
    }
    
    /// On-disk file
    public init(destination: Destination, dataFile: URL) {
        self.destination = destination
        self.data = nil
        self.dataFile = dataFile
        self.sourceURL = nil
    }
}
