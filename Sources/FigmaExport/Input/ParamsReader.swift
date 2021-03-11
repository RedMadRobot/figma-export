import Foundation
import Yams

final class ParamsReader {
    
    private let fileManager: FileManager
    private let inputPath: String

    init(inputPath: String, fileManager: FileManager = .default) {
        self.inputPath = inputPath
        self.fileManager = fileManager
    }
    
    func read() throws -> Params {
        return try readParams(filePath: inputPath)
    }
    
    private func readParams(filePath: String) throws -> Params {
        let data = try Data(contentsOf: URL(fileURLWithPath: filePath))

        let decoder = YAMLDecoder()
        return try decoder.decode(Params.self, from: String(data: data, encoding: .utf8)!)
    }
}
