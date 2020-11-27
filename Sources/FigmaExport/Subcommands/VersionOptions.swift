import ArgumentParser

/// Encapsulates `--version` flag behavior.
struct VersionOptions: ParsableArguments {
    @Flag(name: .shortAndLong, help: "Print the version and exit")
    var version: Bool = false
    
    func validate() throws {
        if version {
            print("0.18.2")
            throw ExitCode.success
        }
    }
}
