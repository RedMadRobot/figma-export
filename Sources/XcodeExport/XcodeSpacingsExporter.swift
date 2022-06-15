import Foundation
import FigmaExportCore
import Stencil

final public class XcodeSpacingsExporter: XcodeExporterBase {
    private let output: XcodeSpacingsOutput

    public init(output: XcodeSpacingsOutput) {
        self.output = output
    }

    public func export(spacings: [Spacing]) throws -> [FileContents] {
        guard let spacingsUrl = output.spacingsUrl else { return [] }
        return [try makeSpacingsStruct(spacings: spacings, spacingsUrl: spacingsUrl)]
    }
    
    private func makeSpacingsStruct(spacings: [Spacing], spacingsUrl: URL) throws -> FileContents {
        let env = makeEnvironment(templatesPath: output.templatesPath)
        let contents = try env.renderTemplate(name: "Spacings.swift.stencil", context: [
            "spacings": spacings.map { spacing in [ "name": spacing.name.lowerCamelCased(), "size": spacing.size ] },
            "addObjcPrefix": output.addObjcAttribute
        ])
        return try makeFileContents(for: contents, url: spacingsUrl)
    }
}
