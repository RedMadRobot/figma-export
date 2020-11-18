import XCTest
import FigmaExportCore
@testable import XcodeExport

final class XcodeIconsExporterTests: XCTestCase {
    
    // MARK: - Properties
    
    private let fileManager = FileManager.default

    private let image1 = Image(name: "image1", url: URL(string: "1")!, format: "pdf")
    private let image2 = Image(name: "image2", url: URL(string: "2")!, format: "pdf")

    // MARK: - Tests
    
    func testExport() throws {
        let output = XcodeImagesOutput(assetsFolderURL: URL(string: "~/")!, assetsInMainBundle: true, uiKitImageExtensionURL: URL(string: "~/UIImage+extension.swift")!)
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
        let output = XcodeImagesOutput(assetsFolderURL: URL(string: "~/")!, assetsInMainBundle: false, uiKitImageExtensionURL: URL(string: "~/UIImage+extension.swift")!)
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
    
    func testExportSwiftUI() throws {
        let output = XcodeImagesOutput(assetsFolderURL: URL(string: "~/")!, assetsInMainBundle: true, swiftUIImageExtensionURL: URL(string: "~/Image+extension.swift")!)
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
        let output = XcodeImagesOutput(assetsFolderURL: URL(string: "~/")!, assetsInMainBundle: false, swiftUIImageExtensionURL: URL(string: "~/Image+extension.swift")!)
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
}
