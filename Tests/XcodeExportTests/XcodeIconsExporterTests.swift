import CustomDump
import XCTest
import Foundation
import FigmaExportCore
@testable import XcodeExport

final class XcodeIconsExporterTests: XCTestCase {

    // MARK: - Properties

    private let image1 = Image(name: "image1", url: URL(string: "1")!, format: "pdf")
    private let image1Dark = Image(name: "image1", url: URL(string: "1_dark")!, format: "pdf")
    private let image2 = Image(name: "image2", url: URL(string: "2")!, format: "pdf")
    private let image2Dark = Image(name: "image2", url: URL(string: "2_dark")!, format: "pdf")
    private let imageWithKeyword = Image(name: "class", url: URL(string: "2")!, format: "pdf")
    private let tabBarIcon = Image(name: "ic24TabBarHome", url: URL(string: "1")!, format: "pdf")
    
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
            icons: [AssetPair(light: ImagePack(image: image1), dark: nil), AssetPair(light: ImagePack(image: image2), dark: nil)],
            append: false
        )

        XCTAssertEqual(result.count, 6)
        XCTAssertTrue(result[0].destination.url.absoluteString.hasSuffix("Contents.json"))
        XCTAssertTrue(result[1].destination.url.absoluteString.hasSuffix("image1.imageset/Contents.json"))
        XCTAssertTrue(result[2].destination.url.absoluteString.hasSuffix("image1.imageset/image1.pdf"))
        XCTAssertTrue(result[3].destination.url.absoluteString.hasSuffix("image2.imageset/Contents.json"))
        XCTAssertTrue(result[4].destination.url.absoluteString.hasSuffix("image2.imageset/image2.pdf"))
        XCTAssertTrue(result[5].destination.url.absoluteString.hasSuffix("UIImage+extension.swift"))

        let content = result[5].data
        XCTAssertNotNil(content)

        let generatedCode = String(data: content!, encoding: .utf8)
        let referenceCode = """
        \(header)

        import UIKit

        private class BundleProvider {
            static let bundle = Bundle(for: BundleProvider.self)
        }

        public extension UIImage {
            static var image1: UIImage { UIImage(named: #function)! }
            static var image2: UIImage { UIImage(named: #function)! }
        }

        """
        XCTAssertNoDifference(generatedCode, referenceCode)
    }

    func testExportPair() throws {
        let output = XcodeImagesOutput(assetsFolderURL: URL(string: "~/")!, assetsInMainBundle: true, uiKitImageExtensionURL: uiKitImageExtensionURL)
        let exporter = XcodeIconsExporter(output: output)
        let result = try exporter.export(
            icons: [AssetPair(light: ImagePack(image: image1), dark: ImagePack(image: image1Dark)),
                    AssetPair(light: ImagePack(image: image2), dark: ImagePack(image: image2Dark))],
            append: false
        )

        XCTAssertEqual(result.count, 8)
        XCTAssertTrue(result[0].destination.url.absoluteString.hasSuffix("Contents.json"))
        XCTAssertTrue(result[1].destination.url.absoluteString.hasSuffix("image1.imageset/Contents.json"))
        XCTAssertTrue(result[2].destination.url.absoluteString.hasSuffix("image1.imageset/image1L.pdf"))
        XCTAssertTrue(result[3].destination.url.absoluteString.hasSuffix("image1.imageset/image1D.pdf"))
        XCTAssertTrue(result[4].destination.url.absoluteString.hasSuffix("image2.imageset/Contents.json"))
        XCTAssertTrue(result[5].destination.url.absoluteString.hasSuffix("image2.imageset/image2L.pdf"))
        XCTAssertTrue(result[6].destination.url.absoluteString.hasSuffix("image2.imageset/image2D.pdf"))
        XCTAssertTrue(result[7].destination.url.absoluteString.hasSuffix("UIImage+extension.swift"))

        let content = result[7].data
        XCTAssertNotNil(content)

        let generatedCode = String(data: content!, encoding: .utf8)
        let referenceCode = """
        \(header)

        import UIKit

        private class BundleProvider {
            static let bundle = Bundle(for: BundleProvider.self)
        }

        public extension UIImage {
            static var image1: UIImage { UIImage(named: #function)! }
            static var image2: UIImage { UIImage(named: #function)! }
        }

        """
        XCTAssertNoDifference(generatedCode, referenceCode)
    }

    func testExportWithObjc() throws {
        let output = XcodeImagesOutput(
            assetsFolderURL: URL(string: "~/")!,
            assetsInMainBundle: true,
            addObjcAttribute: true,
            uiKitImageExtensionURL: URL(string: "~/UIImage+extension.swift")!
        )
        let exporter = XcodeIconsExporter(output: output)
        let result = try exporter.export(
            icons: [AssetPair(light: ImagePack(image: image1), dark: nil), AssetPair(light: ImagePack(image: image2), dark: nil)],
            append: false
        )

        XCTAssertEqual(result.count, 6)
        XCTAssertTrue(result[0].destination.url.absoluteString.hasSuffix("Contents.json"))
        XCTAssertTrue(result[1].destination.url.absoluteString.hasSuffix("image1.imageset/Contents.json"))
        XCTAssertTrue(result[2].destination.url.absoluteString.hasSuffix("image1.imageset/image1.pdf"))
        XCTAssertTrue(result[3].destination.url.absoluteString.hasSuffix("image2.imageset/Contents.json"))
        XCTAssertTrue(result[4].destination.url.absoluteString.hasSuffix("image2.imageset/image2.pdf"))
        XCTAssertTrue(result[5].destination.url.absoluteString.hasSuffix("UIImage+extension.swift"))

        let content = result[5].data
        XCTAssertNotNil(content)

        let generatedCode = String(data: content!, encoding: .utf8)
        let referenceCode = """
        \(header)

        import UIKit

        private class BundleProvider {
            static let bundle = Bundle(for: BundleProvider.self)
        }

        public extension UIImage {
            @objc static var image1: UIImage { UIImage(named: #function)! }
            @objc static var image2: UIImage { UIImage(named: #function)! }
        }

        """
        XCTAssertNoDifference(generatedCode, referenceCode)
    }

    func testExportPairWithObjc() throws {
        let output = XcodeImagesOutput(
            assetsFolderURL: URL(string: "~/")!,
            assetsInMainBundle: true,
            addObjcAttribute: true,
            uiKitImageExtensionURL: URL(string: "~/UIImage+extension.swift")!
        )
        let exporter = XcodeIconsExporter(output: output)
        let result = try exporter.export(
            icons: [AssetPair(light: ImagePack(image: image1), dark: ImagePack(image: image1Dark)),
                    AssetPair(light: ImagePack(image: image2), dark: ImagePack(image: image2Dark))],
            append: false
        )

        XCTAssertEqual(result.count, 8)
        XCTAssertTrue(result[0].destination.url.absoluteString.hasSuffix("Contents.json"))
        XCTAssertTrue(result[1].destination.url.absoluteString.hasSuffix("image1.imageset/Contents.json"))
        XCTAssertTrue(result[2].destination.url.absoluteString.hasSuffix("image1.imageset/image1L.pdf"))
        XCTAssertTrue(result[3].destination.url.absoluteString.hasSuffix("image1.imageset/image1D.pdf"))
        XCTAssertTrue(result[4].destination.url.absoluteString.hasSuffix("image2.imageset/Contents.json"))
        XCTAssertTrue(result[5].destination.url.absoluteString.hasSuffix("image2.imageset/image2L.pdf"))
        XCTAssertTrue(result[6].destination.url.absoluteString.hasSuffix("image2.imageset/image2D.pdf"))
        XCTAssertTrue(result[7].destination.url.absoluteString.hasSuffix("UIImage+extension.swift"))

        let content = result[7].data
        XCTAssertNotNil(content)

        let generatedCode = String(data: content!, encoding: .utf8)
        let referenceCode = """
        \(header)

        import UIKit

        private class BundleProvider {
            static let bundle = Bundle(for: BundleProvider.self)
        }

        public extension UIImage {
            @objc static var image1: UIImage { UIImage(named: #function)! }
            @objc static var image2: UIImage { UIImage(named: #function)! }
        }

        """
        XCTAssertNoDifference(generatedCode, referenceCode)
    }

    func testExportInSeparateBundle() throws {
        let output = XcodeImagesOutput(assetsFolderURL: URL(string: "~/")!, assetsInMainBundle: false, assetsInSwiftPackage: false, uiKitImageExtensionURL: uiKitImageExtensionURL)
        let exporter = XcodeIconsExporter(output: output)
        let result = try exporter.export(
            icons: [AssetPair(light: ImagePack(image: image1), dark: nil), AssetPair(light: ImagePack(image: image2), dark: nil)],
            append: false
        )

        XCTAssertEqual(result.count, 6)
        XCTAssertTrue(result[0].destination.url.absoluteString.hasSuffix("Contents.json"))
        XCTAssertTrue(result[1].destination.url.absoluteString.hasSuffix("image1.imageset/Contents.json"))
        XCTAssertTrue(result[2].destination.url.absoluteString.hasSuffix("image1.imageset/image1.pdf"))
        XCTAssertTrue(result[3].destination.url.absoluteString.hasSuffix("image2.imageset/Contents.json"))
        XCTAssertTrue(result[4].destination.url.absoluteString.hasSuffix("image2.imageset/image2.pdf"))
        XCTAssertTrue(result[5].destination.url.absoluteString.hasSuffix("UIImage+extension.swift"))

        let content = result[5].data
        XCTAssertNotNil(content)

        let generatedCode = String(data: content!, encoding: .utf8)
        let referenceCode = """
        \(header)

        import UIKit

        private class BundleProvider {
            static let bundle = Bundle(for: BundleProvider.self)
        }

        public extension UIImage {
            static var image1: UIImage { UIImage(named: #function, in: BundleProvider.bundle, compatibleWith: nil)! }
            static var image2: UIImage { UIImage(named: #function, in: BundleProvider.bundle, compatibleWith: nil)! }
        }

        """
        XCTAssertNoDifference(generatedCode, referenceCode)
    }

    func testExportPairInSeparateBundle() throws {
        let output = XcodeImagesOutput(assetsFolderURL: URL(string: "~/")!, assetsInMainBundle: false, assetsInSwiftPackage: false, uiKitImageExtensionURL: uiKitImageExtensionURL)
        let exporter = XcodeIconsExporter(output: output)
        let result = try exporter.export(
            icons: [AssetPair(light: ImagePack(image: image1), dark: ImagePack(image: image1Dark)),
                    AssetPair(light: ImagePack(image: image2), dark: ImagePack(image: image2Dark))],
            append: false
        )

        XCTAssertEqual(result.count, 8)
        XCTAssertTrue(result[0].destination.url.absoluteString.hasSuffix("Contents.json"))
        XCTAssertTrue(result[1].destination.url.absoluteString.hasSuffix("image1.imageset/Contents.json"))
        XCTAssertTrue(result[2].destination.url.absoluteString.hasSuffix("image1.imageset/image1L.pdf"))
        XCTAssertTrue(result[3].destination.url.absoluteString.hasSuffix("image1.imageset/image1D.pdf"))
        XCTAssertTrue(result[4].destination.url.absoluteString.hasSuffix("image2.imageset/Contents.json"))
        XCTAssertTrue(result[5].destination.url.absoluteString.hasSuffix("image2.imageset/image2L.pdf"))
        XCTAssertTrue(result[6].destination.url.absoluteString.hasSuffix("image2.imageset/image2D.pdf"))
        XCTAssertTrue(result[7].destination.url.absoluteString.hasSuffix("UIImage+extension.swift"))

        let content = result[7].data
        XCTAssertNotNil(content)

        let generatedCode = String(data: content!, encoding: .utf8)
        let referenceCode = """
        \(header)

        import UIKit

        private class BundleProvider {
            static let bundle = Bundle(for: BundleProvider.self)
        }

        public extension UIImage {
            static var image1: UIImage { UIImage(named: #function, in: BundleProvider.bundle, compatibleWith: nil)! }
            static var image2: UIImage { UIImage(named: #function, in: BundleProvider.bundle, compatibleWith: nil)! }
        }

        """
        XCTAssertNoDifference(generatedCode, referenceCode)
    }

    func testExportInSwiftPackage() throws {
        let output = XcodeImagesOutput(assetsFolderURL: URL(string: "~/")!, assetsInMainBundle: false, assetsInSwiftPackage: true, uiKitImageExtensionURL: uiKitImageExtensionURL)
        let exporter = XcodeIconsExporter(output: output)
        let result = try exporter.export(
            icons: [AssetPair(light: ImagePack(image: image1), dark: nil), AssetPair(light: ImagePack(image: image2), dark: nil)],
            append: false
        )

        XCTAssertEqual(result.count, 6)
        XCTAssertTrue(result[0].destination.url.absoluteString.hasSuffix("Contents.json"))
        XCTAssertTrue(result[1].destination.url.absoluteString.hasSuffix("image1.imageset/Contents.json"))
        XCTAssertTrue(result[2].destination.url.absoluteString.hasSuffix("image1.imageset/image1.pdf"))
        XCTAssertTrue(result[3].destination.url.absoluteString.hasSuffix("image2.imageset/Contents.json"))
        XCTAssertTrue(result[4].destination.url.absoluteString.hasSuffix("image2.imageset/image2.pdf"))
        XCTAssertTrue(result[5].destination.url.absoluteString.hasSuffix("UIImage+extension.swift"))

        let content = result[5].data
        XCTAssertNotNil(content)

        let generatedCode = String(data: content!, encoding: .utf8)
        let referenceCode = """
        \(header)

        import UIKit

        private class BundleProvider {
            static let bundle = Bundle.module
        }

        public extension UIImage {
            static var image1: UIImage { UIImage(named: #function, in: BundleProvider.bundle, compatibleWith: nil)! }
            static var image2: UIImage { UIImage(named: #function, in: BundleProvider.bundle, compatibleWith: nil)! }
        }

        """
        XCTAssertNoDifference(generatedCode, referenceCode)
    }

    func testExportPairInSwiftPackage() throws {
        let output = XcodeImagesOutput(assetsFolderURL: URL(string: "~/")!, assetsInMainBundle: false, assetsInSwiftPackage: true, uiKitImageExtensionURL: uiKitImageExtensionURL)
        let exporter = XcodeIconsExporter(output: output)
        let result = try exporter.export(
            icons: [AssetPair(light: ImagePack(image: image1), dark: ImagePack(image: image1Dark)),
                    AssetPair(light: ImagePack(image: image2), dark: ImagePack(image: image2Dark))],
            append: false
        )

        XCTAssertEqual(result.count, 8)
        XCTAssertTrue(result[0].destination.url.absoluteString.hasSuffix("Contents.json"))
        XCTAssertTrue(result[1].destination.url.absoluteString.hasSuffix("image1.imageset/Contents.json"))
        XCTAssertTrue(result[2].destination.url.absoluteString.hasSuffix("image1.imageset/image1L.pdf"))
        XCTAssertTrue(result[3].destination.url.absoluteString.hasSuffix("image1.imageset/image1D.pdf"))
        XCTAssertTrue(result[4].destination.url.absoluteString.hasSuffix("image2.imageset/Contents.json"))
        XCTAssertTrue(result[5].destination.url.absoluteString.hasSuffix("image2.imageset/image2L.pdf"))
        XCTAssertTrue(result[6].destination.url.absoluteString.hasSuffix("image2.imageset/image2D.pdf"))
        XCTAssertTrue(result[7].destination.url.absoluteString.hasSuffix("UIImage+extension.swift"))

        let content = result[7].data
        XCTAssertNotNil(content)

        let generatedCode = String(data: content!, encoding: .utf8)
        let referenceCode = """
        \(header)

        import UIKit

        private class BundleProvider {
            static let bundle = Bundle.module
        }

        public extension UIImage {
            static var image1: UIImage { UIImage(named: #function, in: BundleProvider.bundle, compatibleWith: nil)! }
            static var image2: UIImage { UIImage(named: #function, in: BundleProvider.bundle, compatibleWith: nil)! }
        }

        """
        XCTAssertNoDifference(generatedCode, referenceCode)
    }

    func testExportSwiftUI() throws {
        let output = XcodeImagesOutput(assetsFolderURL: URL(string: "~/")!, assetsInMainBundle: true, swiftUIImageExtensionURL: swiftUIImageExtensionURL)
        let exporter = XcodeIconsExporter(output: output)
        let result = try exporter.export(
            icons: [AssetPair(light: ImagePack(image: image1), dark: nil), AssetPair(light: ImagePack(image: image2), dark: nil)],
            append: false
        )

        XCTAssertEqual(result.count, 6)
        XCTAssertTrue(result[0].destination.url.absoluteString.hasSuffix("Contents.json"))
        XCTAssertTrue(result[1].destination.url.absoluteString.hasSuffix("image1.imageset/Contents.json"))
        XCTAssertTrue(result[2].destination.url.absoluteString.hasSuffix("image1.imageset/image1.pdf"))
        XCTAssertTrue(result[3].destination.url.absoluteString.hasSuffix("image2.imageset/Contents.json"))
        XCTAssertTrue(result[4].destination.url.absoluteString.hasSuffix("image2.imageset/image2.pdf"))
        XCTAssertTrue(result[5].destination.url.absoluteString.hasSuffix("Image+extension.swift"))

        let content = result[5].data
        XCTAssertNotNil(content)

        let generatedCode = String(data: content!, encoding: .utf8)
        let referenceCode = """
        \(header)

        import SwiftUI

        private class BundleProvider {
            static let bundle = Bundle(for: BundleProvider.self)
        }

        public extension Image {
            static var image1: Image { Image(#function) }
            static var image2: Image { Image(#function) }
        }

        """
        XCTAssertNoDifference(generatedCode, referenceCode)
    }

    func testExportPairSwiftUI() throws {
        let output = XcodeImagesOutput(assetsFolderURL: URL(string: "~/")!, assetsInMainBundle: true, swiftUIImageExtensionURL: swiftUIImageExtensionURL)
        let exporter = XcodeIconsExporter(output: output)
        let result = try exporter.export(
            icons: [AssetPair(light: ImagePack(image: image1), dark: ImagePack(image: image1Dark)),
                    AssetPair(light: ImagePack(image: image2), dark: ImagePack(image: image2Dark))],
            append: false
        )

        XCTAssertEqual(result.count, 8)
        XCTAssertTrue(result[0].destination.url.absoluteString.hasSuffix("Contents.json"))
        XCTAssertTrue(result[1].destination.url.absoluteString.hasSuffix("image1.imageset/Contents.json"))
        XCTAssertTrue(result[2].destination.url.absoluteString.hasSuffix("image1.imageset/image1L.pdf"))
        XCTAssertTrue(result[3].destination.url.absoluteString.hasSuffix("image1.imageset/image1D.pdf"))
        XCTAssertTrue(result[4].destination.url.absoluteString.hasSuffix("image2.imageset/Contents.json"))
        XCTAssertTrue(result[5].destination.url.absoluteString.hasSuffix("image2.imageset/image2L.pdf"))
        XCTAssertTrue(result[6].destination.url.absoluteString.hasSuffix("image2.imageset/image2D.pdf"))
        XCTAssertTrue(result[7].destination.url.absoluteString.hasSuffix("Image+extension.swift"))

        let content = result[7].data
        XCTAssertNotNil(content)

        let generatedCode = String(data: content!, encoding: .utf8)
        let referenceCode = """
        \(header)

        import SwiftUI

        private class BundleProvider {
            static let bundle = Bundle(for: BundleProvider.self)
        }

        public extension Image {
            static var image1: Image { Image(#function) }
            static var image2: Image { Image(#function) }
        }

        """
        XCTAssertNoDifference(generatedCode, referenceCode)
    }

    func testExportSwiftUIInSeparateBundle() throws {
        let output = XcodeImagesOutput(assetsFolderURL: URL(string: "~/")!, assetsInMainBundle: false, swiftUIImageExtensionURL: swiftUIImageExtensionURL)
        let exporter = XcodeIconsExporter(output: output)
        let result = try exporter.export(
            icons: [AssetPair(light: ImagePack(image: image1), dark: nil), AssetPair(light: ImagePack(image: image2), dark: nil)],
            append: false
        )

        XCTAssertEqual(result.count, 6)
        XCTAssertTrue(result[0].destination.url.absoluteString.hasSuffix("Contents.json"))
        XCTAssertTrue(result[1].destination.url.absoluteString.hasSuffix("image1.imageset/Contents.json"))
        XCTAssertTrue(result[2].destination.url.absoluteString.hasSuffix("image1.imageset/image1.pdf"))
        XCTAssertTrue(result[3].destination.url.absoluteString.hasSuffix("image2.imageset/Contents.json"))
        XCTAssertTrue(result[4].destination.url.absoluteString.hasSuffix("image2.imageset/image2.pdf"))
        XCTAssertTrue(result[5].destination.url.absoluteString.hasSuffix("Image+extension.swift"))

        let content = result[5].data
        XCTAssertNotNil(content)

        let generatedCode = String(data: content!, encoding: .utf8)
        let referenceCode = """
        \(header)

        import SwiftUI

        private class BundleProvider {
            static let bundle = Bundle(for: BundleProvider.self)
        }

        public extension Image {
            static var image1: Image { Image(#function, bundle: BundleProvider.bundle) }
            static var image2: Image { Image(#function, bundle: BundleProvider.bundle) }
        }

        """
        XCTAssertNoDifference(generatedCode, referenceCode)
    }

    func testExportPairSwiftUIInSeparateBundle() throws {
        let output = XcodeImagesOutput(assetsFolderURL: URL(string: "~/")!, assetsInMainBundle: false, swiftUIImageExtensionURL: swiftUIImageExtensionURL)
        let exporter = XcodeIconsExporter(output: output)
        let result = try exporter.export(
            icons: [AssetPair(light: ImagePack(image: image1), dark: ImagePack(image: image1Dark)),
                    AssetPair(light: ImagePack(image: image2), dark: ImagePack(image: image2Dark))],
            append: false
        )

        XCTAssertEqual(result.count, 8)
        XCTAssertTrue(result[0].destination.url.absoluteString.hasSuffix("Contents.json"))
        XCTAssertTrue(result[1].destination.url.absoluteString.hasSuffix("image1.imageset/Contents.json"))
        XCTAssertTrue(result[2].destination.url.absoluteString.hasSuffix("image1.imageset/image1L.pdf"))
        XCTAssertTrue(result[3].destination.url.absoluteString.hasSuffix("image1.imageset/image1D.pdf"))
        XCTAssertTrue(result[4].destination.url.absoluteString.hasSuffix("image2.imageset/Contents.json"))
        XCTAssertTrue(result[5].destination.url.absoluteString.hasSuffix("image2.imageset/image2L.pdf"))
        XCTAssertTrue(result[6].destination.url.absoluteString.hasSuffix("image2.imageset/image2D.pdf"))
        XCTAssertTrue(result[7].destination.url.absoluteString.hasSuffix("Image+extension.swift"))

        let content = result[7].data
        XCTAssertNotNil(content)

        let generatedCode = String(data: content!, encoding: .utf8)
        let referenceCode = """
        \(header)

        import SwiftUI

        private class BundleProvider {
            static let bundle = Bundle(for: BundleProvider.self)
        }

        public extension Image {
            static var image1: Image { Image(#function, bundle: BundleProvider.bundle) }
            static var image2: Image { Image(#function, bundle: BundleProvider.bundle) }
        }

        """
        XCTAssertNoDifference(generatedCode, referenceCode)
    }

    func testAppendAfterExport() throws {
        let output = XcodeImagesOutput(
            assetsFolderURL: URL(string: "~/")!,
            assetsInMainBundle: true,
            uiKitImageExtensionURL: uiKitImageExtensionURL
        )
        let exporter = XcodeIconsExporter(output: output)
        let result = try exporter.export(
            icons: [AssetPair(light: ImagePack(image: image1), dark: nil)],
            append: false
        )

        XCTAssertEqual(result.count, 4)
        XCTAssertTrue(result[0].destination.url.absoluteString.hasSuffix("Contents.json"))
        XCTAssertTrue(result[1].destination.url.absoluteString.hasSuffix("image1.imageset/Contents.json"))
        XCTAssertTrue(result[2].destination.url.absoluteString.hasSuffix("image1.imageset/image1.pdf"))
        XCTAssertTrue(result[3].destination.url.absoluteString.hasSuffix("UIImage+extension.swift"))

        try write(file: result[3])

        let appendResult = try exporter.export(
            icons: [AssetPair(light: ImagePack(image: image2), dark: nil)],
            append: true
        )

        XCTAssertEqual(appendResult.count, 4)
        XCTAssertTrue(appendResult[0].destination.url.absoluteString.hasSuffix("Contents.json"))
        XCTAssertTrue(appendResult[1].destination.url.absoluteString.hasSuffix("image2.imageset/Contents.json"))
        XCTAssertTrue(appendResult[2].destination.url.absoluteString.hasSuffix("image2.imageset/image2.pdf"))
        XCTAssertTrue(appendResult[3].destination.url.absoluteString.hasSuffix("UIImage+extension.swift"))
        let resultContent = try XCTUnwrap(appendResult[3].data)

        let generatedCode = String(data: resultContent, encoding: .utf8)
        let referenceCode = """
        \(header)

        import UIKit

        private class BundleProvider {
            static let bundle = Bundle(for: BundleProvider.self)
        }

        public extension UIImage {
            static var image1: UIImage { UIImage(named: #function)! }
            static var image2: UIImage { UIImage(named: #function)! }
        }

        """
        XCTAssertNoDifference(generatedCode, referenceCode)
    }

    func testAppendPairAfterExport() throws {
        let output = XcodeImagesOutput(
            assetsFolderURL: URL(string: "~/")!,
            assetsInMainBundle: true,
            uiKitImageExtensionURL: uiKitImageExtensionURL
        )
        let exporter = XcodeIconsExporter(output: output)
        let result = try exporter.export(
            icons: [AssetPair(light: ImagePack(image: image1), dark: ImagePack(image: image1Dark))],
            append: false
        )

        XCTAssertEqual(result.count, 5)
        XCTAssertTrue(result[0].destination.url.absoluteString.hasSuffix("Contents.json"))
        XCTAssertTrue(result[1].destination.url.absoluteString.hasSuffix("image1.imageset/Contents.json"))
        XCTAssertTrue(result[2].destination.url.absoluteString.hasSuffix("image1.imageset/image1L.pdf"))
        XCTAssertTrue(result[3].destination.url.absoluteString.hasSuffix("image1.imageset/image1D.pdf"))
        XCTAssertTrue(result[4].destination.url.absoluteString.hasSuffix("UIImage+extension.swift"))

        try write(file: result[4])

        let appendResult = try exporter.export(
            icons: [AssetPair(light: ImagePack(image: image2), dark: ImagePack(image: image2Dark))],
            append: true
        )

        XCTAssertEqual(appendResult.count, 5)
        XCTAssertTrue(appendResult[0].destination.url.absoluteString.hasSuffix("Contents.json"))
        XCTAssertTrue(appendResult[1].destination.url.absoluteString.hasSuffix("image2.imageset/Contents.json"))
        XCTAssertTrue(appendResult[2].destination.url.absoluteString.hasSuffix("image2.imageset/image2L.pdf"))
        XCTAssertTrue(appendResult[3].destination.url.absoluteString.hasSuffix("image2.imageset/image2D.pdf"))
        XCTAssertTrue(appendResult[4].destination.url.absoluteString.hasSuffix("UIImage+extension.swift"))
        let resultContent = try XCTUnwrap(appendResult[4].data)

        let generatedCode = String(data: resultContent, encoding: .utf8)
        let referenceCode = """
        \(header)

        import UIKit

        private class BundleProvider {
            static let bundle = Bundle(for: BundleProvider.self)
        }

        public extension UIImage {
            static var image1: UIImage { UIImage(named: #function)! }
            static var image2: UIImage { UIImage(named: #function)! }
        }

        """
        XCTAssertNoDifference(generatedCode, referenceCode)
    }
    
    func testExportImageWithKeyword() throws {
        let output = XcodeImagesOutput(assetsFolderURL: URL(string: "~/")!, assetsInMainBundle: true, uiKitImageExtensionURL: uiKitImageExtensionURL)
        let exporter = XcodeIconsExporter(output: output)
        let result = try exporter.export(
            icons: [AssetPair(light: ImagePack(image: imageWithKeyword), dark: nil)],
            append: false
        )

        let content = try XCTUnwrap(result.last?.data)
        
        let generatedCode = String(data: content, encoding: .utf8)
        let referenceCode = """
        \(header)

        import UIKit

        private class BundleProvider {
            static let bundle = Bundle(for: BundleProvider.self)
        }

        public extension UIImage {
            static var `class`: UIImage { UIImage(named: #function)! }
        }

        """
        XCTAssertNoDifference(generatedCode, referenceCode)
    }
    
    func testExport_preservesVectorRepresentation() throws {
        let output = XcodeImagesOutput(
            assetsFolderURL: URL(string: "~/")!,
            assetsInMainBundle: true,
            preservesVectorRepresentation: ["ic24TabBar*"],
            uiKitImageExtensionURL: uiKitImageExtensionURL
        )
        let exporter = XcodeIconsExporter(output: output)
        let result = try exporter.export(
            icons: [AssetPair(light: ImagePack(image: tabBarIcon), dark: nil)],
            append: false
        )

        XCTAssertEqual(result.count, 4)
        XCTAssertTrue(result[0].destination.url.absoluteString.hasSuffix("Contents.json"))
        XCTAssertTrue(result[1].destination.url.absoluteString.hasSuffix("ic24TabBarHome.imageset/Contents.json"))
        XCTAssertTrue(result[2].destination.url.absoluteString.hasSuffix("ic24TabBarHome.imageset/ic24TabBarHome.pdf"))
        XCTAssertTrue(result[3].destination.url.absoluteString.hasSuffix("UIImage+extension.swift"))

        let content = result[1].data
        XCTAssertNotNil(content)

        let generatedCode = String(data: content!, encoding: .utf8)
        let referenceCode = """
        {
          "images" : [
            {
              "filename" : "ic24TabBarHome.pdf",
              "idiom" : "universal"
            }
          ],
          "info" : {
            "author" : "xcode",
            "version" : 1
          },
          "properties" : {
            "preserves-vector-representation" : true,
            "template-rendering-intent" : "template"
          }
        }
        """
        XCTAssertNoDifference(generatedCode, referenceCode)
    }
    
    func testExport_preservesVectorRepresentation2() throws {
        let output = XcodeImagesOutput(
            assetsFolderURL: URL(string: "~/")!,
            assetsInMainBundle: true,
            preservesVectorRepresentation: ["*"],
            uiKitImageExtensionURL: uiKitImageExtensionURL
        )
        let exporter = XcodeIconsExporter(output: output)
        let result = try exporter.export(
            icons: [AssetPair(light: ImagePack(image: tabBarIcon), dark: nil)],
            append: false
        )

        XCTAssertEqual(result.count, 4)
        XCTAssertTrue(result[0].destination.url.absoluteString.hasSuffix("Contents.json"))
        XCTAssertTrue(result[1].destination.url.absoluteString.hasSuffix("ic24TabBarHome.imageset/Contents.json"))
        XCTAssertTrue(result[2].destination.url.absoluteString.hasSuffix("ic24TabBarHome.imageset/ic24TabBarHome.pdf"))
        XCTAssertTrue(result[3].destination.url.absoluteString.hasSuffix("UIImage+extension.swift"))

        let content = result[1].data
        XCTAssertNotNil(content)

        let generatedCode = String(data: content!, encoding: .utf8)
        let referenceCode = """
        {
          "images" : [
            {
              "filename" : "ic24TabBarHome.pdf",
              "idiom" : "universal"
            }
          ],
          "info" : {
            "author" : "xcode",
            "version" : 1
          },
          "properties" : {
            "preserves-vector-representation" : true,
            "template-rendering-intent" : "template"
          }
        }
        """
        XCTAssertNoDifference(generatedCode, referenceCode)
    }
}

private extension XcodeIconsExporterTests {

    func write(file: FileContents) throws {
        let content = try XCTUnwrap(file.data)

        let directoryURL = URL(fileURLWithPath: file.destination.directory.path)
        try FileManager.default.createDirectory(atPath: directoryURL.path, withIntermediateDirectories: true, attributes: [:])
        let fileURL = URL(fileURLWithPath: file.destination.url.path)

        try content.write(to: fileURL, options: .atomic)
    }

}
