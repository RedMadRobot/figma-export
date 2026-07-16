import ArgumentParser
import FigmaAPI
import Foundation
import Yams

struct FigmaExportOptions: ParsableArguments {
    static let input = "figma-export.yaml"

    @Option(name: .shortAndLong, help: "An input YAML file with figma and platform properties.")
    var input: String = Self.input

    // Set during validate(), excluded from Decodable via CodingKeys
    private(set) var auth: FigmaAuth!
    private(set) var params: Params!

    private enum CodingKeys: String, CodingKey {
        case input
    }

    mutating func validate() throws {
        auth = try Self.resolveAuth()
        params = try readParams(at: input)
    }

    private static func resolveAuth() throws -> FigmaAuth {
        let env = ProcessInfo.processInfo.environment
        if let token = env["FIGMA_OAUTH_TOKEN"] {
            return .oauth(token)
        } else if let token = env["FIGMA_PERSONAL_TOKEN"] {
            return .personalToken(token)
        }
        throw FigmaExportError.accessTokenNotFound
    }

    private func readParams(at path: String) throws -> Params {
        let url = URL(fileURLWithPath: path)
        let data = try Data(contentsOf: url)
        let string = String(decoding: data, as: UTF8.self)
        return try YAMLDecoder().decode(Params.self, from: string)
    }
}
