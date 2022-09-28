import Foundation
import FigmaExportCore

final public class AndroidSpacingsExporter: AndroidExporter {

    private let output: AndroidOutput

    public init(output: AndroidOutput) {
        self.output = output
        super.init(templatesPath: output.templatesPath)
    }

    public func exportSpacings(spacings: [Spacing]) throws -> [FileContents] {
        var files: [FileContents] = []

        // typography.xml
        files.append(try makeSpacingsXMLFileContents(spacings: spacings))

        // Typography.kt
        if
                let composeOutputDirectory = output.composeOutputDirectory,
                let packageName = output.packageName,
                let xmlResourcePackage = output.xmlResourcePackage {

            files.append(
                    try makeSpacingsComposeFileContents(
                            spacings: spacings,
                            outputDirectory: composeOutputDirectory,
                            package: packageName,
                            xmlResourcePackage: xmlResourcePackage
                    )
            )
        }

        return files
    }

    private func makeSpacingsXMLFileContents(spacings: [Spacing]) throws -> FileContents {
        let env = makeEnvironment()
        let contents = try env.renderTemplate(name: "spacings.xml.stencil", context: [
            "spacings": spacings.map { spacing in
                [
                    "name": spacing.name,
                    "size": spacing.size
                ]
            }
        ])

        let directoryURL = output.xmlOutputDirectory.appendingPathComponent("values")
        let fileURL = URL(string: "dimens.xml")!
        return try makeFileContents(for: contents, directory: directoryURL, file: fileURL)
    }

    private func makeSpacingsComposeFileContents(
            spacings: [Spacing],
            outputDirectory: URL,
            package: String,
            xmlResourcePackage: String
    ) throws -> FileContents {
        let spacings: [[String: Any]] = spacings.map { spacing in
            [
                "functionName": spacing.name.lowerCamelCased(),
                "name": spacing.name
            ]
        }
        let context: [String: Any] = [
            "spacings": spacings,
            "package": package,
            "xmlResourcePackage": xmlResourcePackage
        ]
        let env = makeEnvironment()
        let contents = try env.renderTemplate(name: "Spacings.kt.stencil", context: context)

        let fileURL = URL(string: "Spacings.kt")!
        return try makeFileContents(for: contents, directory: outputDirectory, file: fileURL)
    }
}

