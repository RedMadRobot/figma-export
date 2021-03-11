import Foundation

public struct Destination: Equatable {
    
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

public struct FileContents: Equatable {
    
    /// Where to save file?
    public let destination: Destination
    
    /// Raw data (in-memory)
    public let data: Data?
    
    /// Raw data (on-disk)
    public let dataFile: URL?
    
    /// Where to fetch data?
    public let sourceURL: URL?
    
    public var dark: Bool = false
    public var scale: Double = 1.0
    
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
    
    /// Make a copy of the FileContents with different file extension
    /// - Parameter newExtension: New file extension
    public func changingExtension(newExtension: String) -> FileContents {
        var newFile: FileContents
        
        let newFileURL = self.destination.file.deletingPathExtension().appendingPathExtension(newExtension)
        let newDestination = Destination(directory: self.destination.directory, file: newFileURL)
        
        if let sourceURL = sourceURL { // Remote file
            newFile = FileContents(destination: newDestination, sourceURL: sourceURL)
        } else if let dataFile = dataFile { // On-disk file
            newFile = FileContents(destination: newDestination, dataFile: dataFile)
        } else if let data = data { // In-memory file
            newFile = FileContents(destination: newDestination, data: data)
        } else {
            fatalError("Unable to change file extension.")
        }
        
        newFile.scale = self.scale
        newFile.dark = self.dark
        
        return newFile
    }
}
