import FigmaExportCore
import Foundation
import PathKit
import Stencil
import StencilSwiftKit

public class FlutterExporterBase {
    enum Error: Swift.Error, LocalizedError {
        case nameMatchesKeyword(String)

        public var errorDescription: String? {
            switch self {
            case let .nameMatchesKeyword(keyword):
                "Can't make a color with the name \"\(keyword)\", because it matches a Dart keyword."
            }
        }
    }

    private let keywords: Set<String> = [
        "abstract", "as", "assert", "await", "break", "case", "catch", "class", "const", "continue", "covariant",
        "default", "deferred", "do", "dynamic", "else", "enum", "export", "extends", "extension", "external", "factory",
        "false", "final", "finally", "for", "Function", "get", "if", "implements", "import", "in", "interface", "is",
        "late", "library", "mixin", "new", "null", "operator", "part", "required", "rethrow", "return", "set", "static",
        "super", "switch", "this", "throw", "true", "try", "type", "typedef", "var", "void", "with", "while", "yield",
    ]

    func validateName(_ name: String) throws {
        if keywords.contains(name) {
            throw Error.nameMatchesKeyword(name)
        }
    }

    func makeEnvironment(templatesPath: URL?) -> Environment {
        let loader: FileSystemLoader
        if let templateURL = templatesPath {
            loader = FileSystemLoader(paths: [Path(templateURL.path)])
        } else {
            loader = FileSystemLoader(paths: [
                Path(Bundle.module.resourcePath! + "/Resources"),
                Path(Bundle.module.resourcePath!),
            ])
        }
        let ext = Extension()
        ext.registerStencilSwiftExtensions()
        return Environment(loader: loader, extensions: [ext])
    }

    func makeFileContents(for string: String, url: URL) throws -> FileContents {
        let fileURL = URL(string: url.lastPathComponent)!
        let directoryURL = url.deletingLastPathComponent()

        return FileContents(
            destination: Destination(directory: directoryURL, file: fileURL),
            data: string.data(using: .utf8)!
        )
    }

    func makeFileContents(for string: String, directory: URL, file: URL) throws -> FileContents {
        FileContents(
            destination: Destination(directory: directory, file: file),
            data: string.data(using: .utf8)!
        )
    }
}
