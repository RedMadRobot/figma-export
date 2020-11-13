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
    public init(destination: Destination, data: Data, scale: Double = 1.0, dark: Bool = false) {
        self.destination = destination
        self.data = data
        self.dataFile = nil
        self.sourceURL = nil
        self.scale = scale
        self.dark = dark
    }
    
    /// Remote file
    public init(destination: Destination, sourceURL: URL, scale: Double = 1.0, dark: Bool = false) {
        self.destination = destination
        self.data = nil
        self.dataFile = nil
        self.sourceURL = sourceURL
        self.scale = scale
        self.dark = dark
    }
    
    /// On-disk file
    public init(destination: Destination, dataFile: URL, scale: Double = 1.0, dark: Bool = false) {
        self.destination = destination
        self.data = nil
        self.dataFile = dataFile
        self.sourceURL = nil
        self.scale = scale
        self.dark = dark
    }
    
    /// Make a copy of the FileContents with different file extension
    /// - Parameter newExtension: New file extension
    public func changingExtension(newExtension: String) -> FileContents {
        let newFileURL = destination.file
            .deletingPathExtension()
            .appendingPathExtension(newExtension)

        let newDestination = Destination(directory: destination.directory, file: newFileURL)
        
        if let sourceURL = sourceURL { // Remote file
            return FileContents(destination: newDestination, sourceURL: sourceURL, scale: scale, dark: dark)
        } else if let dataFile = dataFile { // On-disk file
            return FileContents(destination: newDestination, dataFile: dataFile, scale: scale, dark: dark)
        } else if let data = data { // In-memory file
            return FileContents(destination: newDestination, data: data, scale: scale, dark: dark)
        } else {
            fatalError("Unable to change file extension.")
        }
    }
}
