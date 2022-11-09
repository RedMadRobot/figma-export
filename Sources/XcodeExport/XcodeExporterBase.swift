import FigmaExportCore
import Foundation
import Stencil
import PathKit
import StencilSwiftKit

public class XcodeExporterBase {
    
    private let declarationKeywords = ["associatedtype", "class", "deinit", "enum", "extension", "fileprivate", "func", "import", "init", "inout", "internal", "let", "open", "operator", "private", "precedencegroup", "protocol", "public", "rethrows", "static", "struct", "subscript", "typealias", "var"]
    
    private let statementKeywords = ["break", "case", "catch", "continue", "default", "defer", "do", "else", "fallthrough", "for", "guard", "if", "in", "repeat", "return", "throw", "switch", "where", "while"]
    
    private let expressionsKeywords = ["Any", "as", "catch", "false", "is", "nil", "rethrows", "self", "Self", "super", "throw", "throws", "true", "try"]
    
    private let otherKeywords = ["associativity", "convenience", "didSet", "dynamic", "final", "get", "indirect", "infix", "lazy", "left", "mutating", "none", "nonmutating", "optional", "override", "postfix", "precedence", "prefix", "Protocol", "required", "right", "set", "some", "Type", "unowned", "weak", "willSet"]
    
    func normalizeName(_ name: String) -> String {
        let keyword = (declarationKeywords + statementKeywords + expressionsKeywords + otherKeywords).first { keyword in
            name == keyword
        }
        if let keyword {
            return "`\(keyword)`"
        } else {
            return name
        }
    }
    
    func makeEnvironment(templatesPath: URL?) -> Environment {
        let loader: FileSystemLoader
        if let templateURL = templatesPath {
            loader = FileSystemLoader(paths: [Path(templateURL.path)])
        } else {
            loader = FileSystemLoader(paths: [
                Path(Bundle.module.resourcePath! + "/Resources"),
                Path(Bundle.module.resourcePath!)
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
