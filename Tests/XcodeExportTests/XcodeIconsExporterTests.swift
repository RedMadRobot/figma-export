import XCTest
import Foundation
import FigmaExportCore
@testable import XcodeExport

final class XcodeIconsExporterTests: XCTestCase {
    
    // MARK: - Properties

    private let image1 = Image(name: "image1", url: URL(string: "1")!, format: "pdf")
    private let image2 = Image(name: "image2", url: URL(string: "2")!, format: "pdf")

    private let uiKitImageExtensionURL = FileManager.default
        .temporaryDirectory
        .appendingPathComponent("UIImage+extension.swift")
    private let swiftUIImageExtensionURL = FileManager.default
        .temporaryDirectory
        .appendingPathComponent("Image+extension.swift")

    // MARK: - Tests
    
    func testExport() throws {
        let output = XcodeImagesOutput(assetsFolderURL: URL(string: "~/")!, assetsInMainBundle: true, uiKitImageExtensionURL: uiKitImageExtensionURL)
        let exporter = XcodeIconsExporter(output: output)
        let result = try exporter.export(
            icons: [ImagePack(image: image1), ImagePack(image: image2)],
            append: false
        )
        
        XCTAssertEqual(result.count, 6)
        XCTAssertTrue(result[0].destination.url.absoluteString.hasSuffix("Contents.json"))
        XCTAssertTrue(result[1].destination.url.absoluteString.hasSuffix("image1.imageset/image1.pdf"))
        XCTAssertTrue(result[2].destination.url.absoluteString.hasSuffix("image1.imageset/Contents.json"))
        XCTAssertTrue(result[3].destination.url.absoluteString.hasSuffix("image2.imageset/image2.pdf"))
        XCTAssertTrue(result[4].destination.url.absoluteString.hasSuffix("image2.imageset/Contents.json"))
        XCTAssertTrue(result[5].destination.url.absoluteString.hasSuffix("UIImage+extension.swift"))

        let content = result[5].data
        XCTAssertNotNil(content)

        let generatedCode = String(data: content!, encoding: .utf8)
        let referenceCode = """
        //
        //  The code generated using FigmaExport — Command line utility to export
        //  colors, typography, icons and images from Figma to Xcode project.
        //
        //  https://github.com/RedMadRobot/figma-export
        //
        //  Don’t edit this code manually to avoid runtime crashes
        //

        import UIKit

        public extension UIImage {
            static var image1: UIImage { UIImage(named: #function)! }
            static var image2: UIImage { UIImage(named: #function)! }
        }

        """
        XCTAssertEqual(generatedCode, referenceCode)
    }
    
    func testExportInSeparateBundle() throws {
        let output = XcodeImagesOutput(assetsFolderURL: URL(string: "~/")!, assetsInMainBundle: false, assetsInSwiftPackage: false, uiKitImageExtensionURL: uiKitImageExtensionURL)
        let exporter = XcodeIconsExporter(output: output)
        let result = try exporter.export(
            icons: [ImagePack(image: image1), ImagePack(image: image2)],
            append: false
        )
        
        XCTAssertEqual(result.count, 6)
        XCTAssertTrue(result[0].destination.url.absoluteString.hasSuffix("Contents.json"))
        XCTAssertTrue(result[1].destination.url.absoluteString.hasSuffix("image1.imageset/image1.pdf"))
        XCTAssertTrue(result[2].destination.url.absoluteString.hasSuffix("image1.imageset/Contents.json"))
        XCTAssertTrue(result[3].destination.url.absoluteString.hasSuffix("image2.imageset/image2.pdf"))
        XCTAssertTrue(result[4].destination.url.absoluteString.hasSuffix("image2.imageset/Contents.json"))
        XCTAssertTrue(result[5].destination.url.absoluteString.hasSuffix("UIImage+extension.swift"))

        let content = result[5].data
        XCTAssertNotNil(content)

        let generatedCode = String(data: content!, encoding: .utf8)
        let referenceCode = """
        //
        //  The code generated using FigmaExport — Command line utility to export
        //  colors, typography, icons and images from Figma to Xcode project.
        //
        //  https://github.com/RedMadRobot/figma-export
        //
        //  Don’t edit this code manually to avoid runtime crashes
        //

        import UIKit

        private class BundleProvider {
            static let bundle = Bundle(for: BundleProvider.self)
        }

        public extension UIImage {
            static var image1: UIImage { UIImage(named: #function, in: BundleProvider.bundle, compatibleWith: nil)! }
            static var image2: UIImage { UIImage(named: #function, in: BundleProvider.bundle, compatibleWith: nil)! }
        }

        """
        XCTAssertEqual(generatedCode, referenceCode)
    }

    func testExportInSwiftPackage() throws {
        let output = XcodeImagesOutput(assetsFolderURL: URL(string: "~/")!, assetsInMainBundle: false, assetsInSwiftPackage: true, uiKitImageExtensionURL: uiKitImageExtensionURL)
        let exporter = XcodeIconsExporter(output: output)
        let result = try exporter.export(
            icons: [ImagePack(image: image1), ImagePack(image: image2)],
            append: false
        )

        XCTAssertEqual(result.count, 6)
        XCTAssertTrue(result[0].destination.url.absoluteString.hasSuffix("Contents.json"))
        XCTAssertTrue(result[1].destination.url.absoluteString.hasSuffix("image1.imageset/image1.pdf"))
        XCTAssertTrue(result[2].destination.url.absoluteString.hasSuffix("image1.imageset/Contents.json"))
        XCTAssertTrue(result[3].destination.url.absoluteString.hasSuffix("image2.imageset/image2.pdf"))
        XCTAssertTrue(result[4].destination.url.absoluteString.hasSuffix("image2.imageset/Contents.json"))
        XCTAssertTrue(result[5].destination.url.absoluteString.hasSuffix("UIImage+extension.swift"))

        let content = result[5].data
        XCTAssertNotNil(content)

        let generatedCode = String(data: content!, encoding: .utf8)
        let referenceCode = """
        //
        //  The code generated using FigmaExport — Command line utility to export
        //  colors, typography, icons and images from Figma to Xcode project.
        //
        //  https://github.com/RedMadRobot/figma-export
        //
        //  Don’t edit this code manually to avoid runtime crashes
        //

        import UIKit

        private class BundleProvider {
            static let bundle = Bundle.module
        }

        public extension UIImage {
            static var image1: UIImage { UIImage(named: #function, in: BundleProvider.bundle, compatibleWith: nil)! }
            static var image2: UIImage { UIImage(named: #function, in: BundleProvider.bundle, compatibleWith: nil)! }
        }

        """
        XCTAssertEqual(generatedCode, referenceCode)
    }
    
    func testExportSwiftUI() throws {
        let output = XcodeImagesOutput(assetsFolderURL: URL(string: "~/")!, assetsInMainBundle: true, swiftUIImageExtensionURL: swiftUIImageExtensionURL)
        let exporter = XcodeIconsExporter(output: output)
        let result = try exporter.export(
            icons: [ImagePack(image: image1), ImagePack(image: image2)],
            append: false
        )

        XCTAssertEqual(result.count, 6)
        XCTAssertTrue(result[0].destination.url.absoluteString.hasSuffix("Contents.json"))
        XCTAssertTrue(result[1].destination.url.absoluteString.hasSuffix("image1.imageset/image1.pdf"))
        XCTAssertTrue(result[2].destination.url.absoluteString.hasSuffix("image1.imageset/Contents.json"))
        XCTAssertTrue(result[3].destination.url.absoluteString.hasSuffix("image2.imageset/image2.pdf"))
        XCTAssertTrue(result[4].destination.url.absoluteString.hasSuffix("image2.imageset/Contents.json"))
        XCTAssertTrue(result[5].destination.url.absoluteString.hasSuffix("Image+extension.swift"))

        let content = result[5].data
        XCTAssertNotNil(content)

        let generatedCode = String(data: content!, encoding: .utf8)
        let referenceCode = """
        //
        //  The code generated using FigmaExport — Command line utility to export
        //  colors, typography, icons and images from Figma to Xcode project.
        //
        //  https://github.com/RedMadRobot/figma-export
        //
        //  Don’t edit this code manually to avoid runtime crashes
        //

        import SwiftUI

        public extension Image {
            static var image1: Image { Image(#function) }
            static var image2: Image { Image(#function) }
        }

        """
        XCTAssertEqual(generatedCode, referenceCode)
    }
    
    func testExportSwiftUIInSeparateBundle() throws {
        let output = XcodeImagesOutput(assetsFolderURL: URL(string: "~/")!, assetsInMainBundle: false, swiftUIImageExtensionURL: swiftUIImageExtensionURL)
        let exporter = XcodeIconsExporter(output: output)
        let result = try exporter.export(
            icons: [ImagePack(image: image1), ImagePack(image: image2)],
            append: false
        )

        XCTAssertEqual(result.count, 6)
        XCTAssertTrue(result[0].destination.url.absoluteString.hasSuffix("Contents.json"))
        XCTAssertTrue(result[1].destination.url.absoluteString.hasSuffix("image1.imageset/image1.pdf"))
        XCTAssertTrue(result[2].destination.url.absoluteString.hasSuffix("image1.imageset/Contents.json"))
        XCTAssertTrue(result[3].destination.url.absoluteString.hasSuffix("image2.imageset/image2.pdf"))
        XCTAssertTrue(result[4].destination.url.absoluteString.hasSuffix("image2.imageset/Contents.json"))
        XCTAssertTrue(result[5].destination.url.absoluteString.hasSuffix("Image+extension.swift"))

        let content = result[5].data
        XCTAssertNotNil(content)

        let generatedCode = String(data: content!, encoding: .utf8)
        let referenceCode = """
        //
        //  The code generated using FigmaExport — Command line utility to export
        //  colors, typography, icons and images from Figma to Xcode project.
        //
        //  https://github.com/RedMadRobot/figma-export
        //
        //  Don’t edit this code manually to avoid runtime crashes
        //

        import SwiftUI

        private class BundleProvider {
            static let bundle = Bundle(for: BundleProvider.self)
        }

        public extension Image {
            static var image1: Image { Image(#function, bundle: BundleProvider.bundle) }
            static var image2: Image { Image(#function, bundle: BundleProvider.bundle) }
        }

        """
        XCTAssertEqual(generatedCode, referenceCode)
    }

    func testAppendAfterExport() throws {
        let output = XcodeImagesOutput(
            assetsFolderURL: URL(string: "~/")!,
            assetsInMainBundle: true,
            uiKitImageExtensionURL: uiKitImageExtensionURL
        )
        let exporter = XcodeIconsExporter(output: output)
        let result = try exporter.export(
            icons: [ImagePack(image: image1)],
            append: false
        )

        XCTAssertEqual(result.count, 4)
        XCTAssertTrue(result[0].destination.url.absoluteString.hasSuffix("Contents.json"))
        XCTAssertTrue(result[1].destination.url.absoluteString.hasSuffix("image1.imageset/image1.pdf"))
        XCTAssertTrue(result[2].destination.url.absoluteString.hasSuffix("image1.imageset/Contents.json"))
        XCTAssertTrue(result[3].destination.url.absoluteString.hasSuffix("UIImage+extension.swift"))

        try write(file: result[3])

        let appendResult = try exporter.export(
            icons: [ImagePack(image: image2)],
            append: true
        )

        XCTAssertEqual(appendResult.count, 4)
        XCTAssertTrue(appendResult[0].destination.url.absoluteString.hasSuffix("Contents.json"))
        XCTAssertTrue(appendResult[1].destination.url.absoluteString.hasSuffix("image2.imageset/image2.pdf"))

        let resultContent = try XCTUnwrap(appendResult[3].data)

        let generatedCode = String(data: resultContent, encoding: .utf8)
        let referenceCode = """
        //
        //  The code generated using FigmaExport — Command line utility to export
        //  colors, typography, icons and images from Figma to Xcode project.
        //
        //  https://github.com/RedMadRobot/figma-export
        //
        //  Don’t edit this code manually to avoid runtime crashes
        //

        import UIKit

        public extension UIImage {
            static var image1: UIImage { UIImage(named: #function)! }
            static var image2: UIImage { UIImage(named: #function)! }
        }

        """
        XCTAssertEqual(generatedCode, referenceCode)
    }
}

private extension XcodeIconsExporterTests {

    func write(file: FileContents) throws {
        let content = try XCTUnwrap(file.data)

        let directoryURL = URL(fileURLWithPath: file.destination.directory.path)
        try FileManager.default.createDirectory(atPath: directoryURL.path, withIntermediateDirectories: true, attributes: [:])
        let fileURL = URL(fileURLWithPath: file.destination.url.path)

        try content.write(to: fileURL, options: .atomicWrite)
    }

}
