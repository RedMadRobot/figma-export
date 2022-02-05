import Foundation
import FigmaExportCore
import Stencil

final public class AndroidComposeIconExporter: AndroidExporter {

    private let output: AndroidOutput

    public init(output: AndroidOutput) {
        self.output = output
        super.init(templatesPath: output.templatesPath)
    }

    public func exportIcons(iconNames: [String]) throws -> FileContents? {
        guard
            let outputDirectory = output.composeOutputDirectory,
            let packageName = output.packageName,
            let package = output.xmlResourcePackage
        else {
            return nil
        }
        let fileURL = URL(string: "Icons.kt")!
        let contents = try makeComposeIconsContents(iconNames, package: packageName, xmlResourcePackage: package)
        return try makeFileContents(for: contents, directory: outputDirectory, file: fileURL)
    }
    
    private func makeComposeIconsContents(
        _ iconNames: [String],
        package: String,
        xmlResourcePackage: String
    ) throws -> String {
        let icons: [[String: String]] = iconNames.map {
            ["name": $0, "functionName": $0.camelCased()]
        }
        let context: [String: Any] = [
            "package": package,
            "xmlResourcePackage": xmlResourcePackage,
            "icons": icons
        ]
        let env = makeEnvironment(trimBehavior: .none)
        return try env.renderTemplate(name: "Icons.kt.stencil", context: context)
    }
}
