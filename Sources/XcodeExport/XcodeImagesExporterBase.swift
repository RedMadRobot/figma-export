import FigmaExportCore
import Foundation

public class XcodeImagesExporterBase: XcodeExporterBase {
    
    enum Error: LocalizedError {
        case templateDoesNotSupportAppending
        
        var errorDescription: String? {
            "Custom templates doesn’t supported when \"append\" property is equal to true. Use default templates or change \"append\" property to false"
        }
    }
    
    let output: XcodeImagesOutput
    
    public init(output: XcodeImagesOutput) {
        self.output = output
    }
    
    func generateExtensions(names: [String], append: Bool) throws -> [FileContents] {
        if output.templatesPath != nil && append == true {
            throw Error.templateDoesNotSupportAppending
        }
                
        var files = [FileContents]()
        
        // SwiftUI extension for Image
        if let url = output.swiftUIImageExtensionURL {
            files.append(try makeSwiftUIExtension(for: names, append: append, extensionFileURL: url))
        }
        
        // UIKit extension for UIImage
        if let url = output.uiKitImageExtensionURL {
            files.append(try makeUIKitExtension(for: names, append: append, extensionFileURL: url))
        }
        
        return files
    }
    
    private func makeSwiftUIExtension(for names: [String], append: Bool, extensionFileURL url: URL) throws -> FileContents {
        let contents: String
        if append {
            let partialContents = try makeExtensionContents(names: names, templateName: "Image+extension.swift.stencil.include")
            contents = try appendContent(string: partialContents, to: url)
        }
        else {
            contents = try makeExtensionContents(names: names, templateName: "Image+extension.swift.stencil")
        }
        return try makeFileContents(for: contents, url: url)
    }
    
    private func makeUIKitExtension(for names: [String], append: Bool, extensionFileURL url: URL) throws -> FileContents {
        let contents: String
        
        if append {
            let partialContents = try makeExtensionContents(names: names, templateName: "UIImage+extension.swift.stencil.include")
            contents = try appendContent(string: partialContents, to: url)
        } else {
            contents = try makeExtensionContents(names: names, templateName: "UIImage+extension.swift.stencil")
        }
        
        return try makeFileContents(for: contents, url: url)
    }
    
    private func makeExtensionContents(names: [String], templateName: String) throws -> String {
        let context: [String: Any] = [
            "addObjcPrefix": output.addObjcAttribute,
            "assetsInSwiftPackage": output.assetsInSwiftPackage,
            "resourceBundleNames": output.resourceBundleNames ?? [],
            "assetsInMainBundle": output.assetsInMainBundle,
            "images": names.map { ["name": $0] },
        ]
        let env = makeEnvironment(templatesPath: output.templatesPath)
        return try env.renderTemplate(name: templateName, context: context)
    }
    
    private func appendContent(string: String, to fileURL: URL) throws -> String {
        var existingContents = try String(
            contentsOf: URL(fileURLWithPath: fileURL.path),
            encoding: .utf8
        )
        let string = string + "\n}\n"
        
        if let index = existingContents.dropLast(2).lastIndex(of: "}") {
            let newIndex = existingContents.index(after: index)
            existingContents.replaceSubrange(
                newIndex..<existingContents.endIndex,
                with: string
            )
        }
        return existingContents
    }
}
