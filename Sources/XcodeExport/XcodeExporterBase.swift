public class XcodeExporterBase {
    
    private let declarationKeywords = ["associatedtype", "class", "deinit", "enum", "extension", "fileprivate", "func", "import", "init", "inout", "internal", "let", "open", "operator", "private", "precedencegroup", "protocol", "public", "rethrows", "static", "struct", "subscript", "typealias", "var"]
    
    private let statementKeywords = ["break", "case", "catch", "continue", "default", "defer", "do", "else", "fallthrough", "for", "guard", "if", "in", "repeat", "return", "throw", "switch", "where", "while"]
    
    private let expressionsKeywords = ["Any", "as", "catch", "false", "is", "nil", "rethrows", "self", "Self", "super", "throw", "throws", "true", "try"]
    
    private let otherKeywords = ["associativity", "convenience", "didSet", "dynamic", "final", "get", "indirect", "infix", "lazy", "left", "mutating", "none", "nonmutating", "optional", "override", "postfix", "precedence", "prefix", "Protocol", "required", "right", "set", "some", "Type", "unowned", "weak", "willSet"]
    
    func normalizeName(_ name: String) -> String {
        let keyword = (declarationKeywords + statementKeywords + expressionsKeywords + otherKeywords).first { keyword in
            name == keyword
        }
        if let keyword = keyword {
            return "`\(keyword)`"
        } else {
            return name
        }
    }
}
