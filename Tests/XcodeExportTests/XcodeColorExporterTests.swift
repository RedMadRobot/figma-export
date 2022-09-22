import XCTest
import FigmaExportCore
@testable import XcodeExport
import CustomDump

final class XcodeColorExporterTests: XCTestCase {
    
    // MARK: - Properties
    
    private let fileManager = FileManager.default
    private var colorsFile: URL!
    private var colorsAssetCatalog: URL!
    
    private let colorPair1 = AssetPair<Color>(
        light: Color(name: "colorPair1", red: 1, green: 1, blue: 1, alpha: 1),
        dark: Color(name: "colorPair1", red: 0, green: 0, blue: 0, alpha: 1))
    
    private let colorPair2 = AssetPair<Color>(
        light: Color(name: "colorPair2", red: 119.0/255.0, green: 3.0/255.0, blue: 1.0, alpha: 0.5),
        dark: nil)
    
    private lazy var color3: Color = {
        var color = Color(name: "background/primary", red: 119.0/255.0, green: 3.0/255.0, blue: 1.0, alpha: 0.5)
        color.name = "backgroundPrimary"
        return color
    }()
    
    private lazy var colorPair3 = AssetPair<Color>(
        light: color3,
        dark: nil)
    
    private let colorWithKeyword = AssetPair<Color>(
        light: Color(name: "class", platform: .ios, red: 1, green: 1, blue: 1, alpha: 1),
        dark: nil
    )
    
    // MARK: - Setup
    
    override func setUp() {
        super.setUp()
        colorsFile = fileManager.temporaryDirectory.appendingPathComponent("Colors.swift")
        colorsAssetCatalog = fileManager.temporaryDirectory.appendingPathComponent("Assets.xcassets/Colors")
    }
    
    // MARK: - Tests
    
    func testExport_without_assets() throws {
        let output = XcodeColorsOutput(assetsColorsURL: nil, assetsInMainBundle: true, colorSwiftURL: colorsFile)
        let exporter = XcodeColorExporter(output: output)
        
        let result = try exporter.export(colorPairs: [colorPair1, colorPair2])
        XCTAssertEqual(result.count, 1)
        
        let content = result[0].data
        XCTAssertNotNil(content)

        try assertCodeEquals(content, """
        \(header)

        import UIKit

        private class BundleProvider {
            static let bundle = Bundle(for: BundleProvider.self)
        }

        public extension UIColor {
            static var colorPair1: UIColor {
                UIColor { traitCollection -> UIColor in
                    if traitCollection.userInterfaceStyle == .dark {
                        return UIColor(red: 0.000, green: 0.000, blue: 0.000, alpha: 1.000)
                    } else {
                        return UIColor(red: 1.000, green: 1.000, blue: 1.000, alpha: 1.000)
                    }
                }
            }
            static var colorPair2: UIColor {
                UIColor(red: 0.467, green: 0.012, blue: 1.000, alpha: 0.500)
            }
        }

        """)
    }
    
    func testExport_with_assets() throws {
        let output = XcodeColorsOutput(assetsColorsURL: colorsAssetCatalog, assetsInMainBundle: true, colorSwiftURL: colorsFile)
        let exporter = XcodeColorExporter(output: output)

        let result = try exporter.export(colorPairs: [colorPair1, colorPair2])
        
        XCTAssertEqual(result.count, 4)
        XCTAssertTrue(result[0].destination.url.absoluteString.hasSuffix("Colors.swift"))
        XCTAssertTrue(result[1].destination.url.absoluteString.hasSuffix("Assets.xcassets/Colors/Contents.json"))
        XCTAssertTrue(result[2].destination.url.absoluteString.hasSuffix("colorPair1.colorset/Contents.json"))
        XCTAssertTrue(result[3].destination.url.absoluteString.hasSuffix("colorPair2.colorset/Contents.json"))
        
        let content = result[0].data
        XCTAssertNotNil(content)

        try assertCodeEquals(content, """
        \(header)

        import UIKit

        private class BundleProvider {
            static let bundle = Bundle(for: BundleProvider.self)
        }

        public extension UIColor {
            static var colorPair1: UIColor { UIColor(named: #function)! }
            static var colorPair2: UIColor { UIColor(named: #function)! }
        }

        """)
    }

    func testExport_with_objc() throws {
        let output = XcodeColorsOutput(
            assetsColorsURL: colorsAssetCatalog,
            assetsInMainBundle: true,
            addObjcAttribute: true,
            colorSwiftURL: colorsFile
        )
        let exporter = XcodeColorExporter(output: output)

        let result = try exporter.export(colorPairs: [colorPair1, colorPair2])

        XCTAssertEqual(result.count, 4)
        XCTAssertTrue(result[0].destination.url.absoluteString.hasSuffix("Colors.swift"))
        XCTAssertTrue(result[1].destination.url.absoluteString.hasSuffix("Assets.xcassets/Colors/Contents.json"))
        XCTAssertTrue(result[2].destination.url.absoluteString.hasSuffix("colorPair1.colorset/Contents.json"))
        XCTAssertTrue(result[3].destination.url.absoluteString.hasSuffix("colorPair2.colorset/Contents.json"))

        let content = result[0].data
        XCTAssertNotNil(content)

        try assertCodeEquals(content, """
        \(header)

        import UIKit

        private class BundleProvider {
            static let bundle = Bundle(for: BundleProvider.self)
        }

        public extension UIColor {
            @objc static var colorPair1: UIColor { UIColor(named: #function)! }
            @objc static var colorPair2: UIColor { UIColor(named: #function)! }
        }

        """)
    }
    
    func testExport_with_assets_in_separate_bundle() throws {
        let output = XcodeColorsOutput(assetsColorsURL: colorsAssetCatalog, assetsInMainBundle: false, colorSwiftURL: colorsFile)
        let exporter = XcodeColorExporter(output: output)

        let result = try exporter.export(colorPairs: [colorPair1, colorPair2])
        
        XCTAssertEqual(result.count, 4)
        XCTAssertTrue(result[0].destination.url.absoluteString.hasSuffix("Colors.swift"))
        XCTAssertTrue(result[1].destination.url.absoluteString.hasSuffix("Assets.xcassets/Colors/Contents.json"))
        XCTAssertTrue(result[2].destination.url.absoluteString.hasSuffix("colorPair1.colorset/Contents.json"))
        XCTAssertTrue(result[3].destination.url.absoluteString.hasSuffix("colorPair2.colorset/Contents.json"))
        
        let content = result[0].data
        XCTAssertNotNil(content)

        try assertCodeEquals(content, """
        \(header)

        import UIKit

        private class BundleProvider {
            static let bundle = Bundle(for: BundleProvider.self)
        }

        public extension UIColor {
            static var colorPair1: UIColor { UIColor(named: #function, in: BundleProvider.bundle, compatibleWith: nil)! }
            static var colorPair2: UIColor { UIColor(named: #function, in: BundleProvider.bundle, compatibleWith: nil)! }
        }

        """)
    }

    func testExport_with_assets_in_swift_package() throws {
        let output = XcodeColorsOutput(assetsColorsURL: colorsAssetCatalog, assetsInMainBundle: false, assetsInSwiftPackage: true, colorSwiftURL: colorsFile)
        let exporter = XcodeColorExporter(output: output)

        let result = try exporter.export(colorPairs: [colorPair1, colorPair2])

        XCTAssertEqual(result.count, 4)
        XCTAssertTrue(result[0].destination.url.absoluteString.hasSuffix("Colors.swift"))
        XCTAssertTrue(result[1].destination.url.absoluteString.hasSuffix("Assets.xcassets/Colors/Contents.json"))
        XCTAssertTrue(result[2].destination.url.absoluteString.hasSuffix("colorPair1.colorset/Contents.json"))
        XCTAssertTrue(result[3].destination.url.absoluteString.hasSuffix("colorPair2.colorset/Contents.json"))

        let content = result[0].data
        XCTAssertNotNil(content)

        try assertCodeEquals(content, """
        \(header)

        import UIKit

        private class BundleProvider {
            static let bundle = Bundle.module
        }

        public extension UIColor {
            static var colorPair1: UIColor { UIColor(named: #function, in: BundleProvider.bundle, compatibleWith: nil)! }
            static var colorPair2: UIColor { UIColor(named: #function, in: BundleProvider.bundle, compatibleWith: nil)! }
        }

        """)
    }

    func testExport_swiftui() throws {
        let output = XcodeColorsOutput(assetsColorsURL: colorsAssetCatalog, assetsInMainBundle: true, colorSwiftURL: nil, swiftuiColorSwiftURL: colorsFile)
        let exporter = XcodeColorExporter(output: output)

        let result = try exporter.export(colorPairs: [colorPair1, colorPair2])

        XCTAssertEqual(result.count, 4)
        XCTAssertTrue(result[0].destination.url.absoluteString.hasSuffix("Colors.swift"))
        XCTAssertTrue(result[1].destination.url.absoluteString.hasSuffix("Assets.xcassets/Colors/Contents.json"))
        XCTAssertTrue(result[2].destination.url.absoluteString.hasSuffix("colorPair1.colorset/Contents.json"))
        XCTAssertTrue(result[3].destination.url.absoluteString.hasSuffix("colorPair2.colorset/Contents.json"))

        let content = result[0].data

        try assertCodeEquals(content, """
        \(header)

        import SwiftUI

        private class BundleProvider {
            static let bundle = Bundle(for: BundleProvider.self)
        }

        public extension ShapeStyle where Self == Color {
            static var colorPair1: Color { Color(#function) }
            static var colorPair2: Color { Color(#function) }
        }

        """)
    }

    func testExport_swiftui_and_assets_in_swift_package() throws {
        let output = XcodeColorsOutput(
            assetsColorsURL: colorsAssetCatalog,
            assetsInMainBundle: false,
            assetsInSwiftPackage: true,
            colorSwiftURL: nil,
            swiftuiColorSwiftURL: colorsFile
        )
        let exporter = XcodeColorExporter(output: output)

        let result = try exporter.export(colorPairs: [colorPair1, colorPair2])

        XCTAssertEqual(result.count, 4)
        XCTAssertTrue(result[0].destination.url.absoluteString.hasSuffix("Colors.swift"))
        XCTAssertTrue(result[1].destination.url.absoluteString.hasSuffix("Assets.xcassets/Colors/Contents.json"))
        XCTAssertTrue(result[2].destination.url.absoluteString.hasSuffix("colorPair1.colorset/Contents.json"))
        XCTAssertTrue(result[3].destination.url.absoluteString.hasSuffix("colorPair2.colorset/Contents.json"))

        let content = result[0].data

        try assertCodeEquals(content, """
        \(header)

        import SwiftUI

        private class BundleProvider {
            static let bundle = Bundle.module
        }

        public extension ShapeStyle where Self == Color {
            static var colorPair1: Color { Color(#function, bundle: BundleProvider.bundle) }
            static var colorPair2: Color { Color(#function, bundle: BundleProvider.bundle) }
        }

        """)
    }
    
    func testExport_withProvidesNamespace() throws {
        let output = XcodeColorsOutput(
            assetsColorsURL: colorsAssetCatalog,
            assetsInMainBundle: true,
            colorSwiftURL: colorsFile,
            groupUsingNamespace: true
        )
        let exporter = XcodeColorExporter(output: output)

        let result = try exporter.export(colorPairs: [colorPair3])
        
        XCTAssertEqual(result.count, 4)
        XCTAssertTrue(result[0].destination.url.absoluteString.hasSuffix("Colors.swift"))
        XCTAssertTrue(result[1].destination.url.absoluteString.hasSuffix("Assets.xcassets/Colors/Contents.json"))
        XCTAssertTrue(result[2].destination.url.absoluteString.hasSuffix("background/Contents.json"))
        XCTAssertTrue(result[3].destination.url.absoluteString.hasSuffix("primary.colorset/Contents.json"))
        
        let content = result[0].data
        XCTAssertNotNil(content)

        try assertCodeEquals(content, """
        \(header)

        import UIKit

        private class BundleProvider {
            static let bundle = Bundle(for: BundleProvider.self)
        }

        public extension UIColor {
            static var backgroundPrimary: UIColor { UIColor(named: "background/primary")! }
        }

        """)
    }
    
    func testExportWhenNameIsSwiftKeyword() throws {
        let output = XcodeColorsOutput(assetsColorsURL: nil, assetsInMainBundle: true, colorSwiftURL: colorsFile)
        let exporter = XcodeColorExporter(output: output)
        
        let result = try exporter.export(colorPairs: [colorWithKeyword])

        XCTAssertEqual(result.count, 1)
        let content = result[0].data
        XCTAssertNotNil(content)

        try assertCodeEquals(content, """
        \(header)

        import UIKit

        private class BundleProvider {
            static let bundle = Bundle(for: BundleProvider.self)
        }

        public extension UIColor {
            static var `class`: UIColor {
                UIColor(red: 1.000, green: 1.000, blue: 1.000, alpha: 1.000)
            }
        }

        """)
    }

    func testExport_without_assets_swiftui() throws {
        let output = XcodeColorsOutput(
            assetsColorsURL: nil,
            assetsInMainBundle: true,
            colorSwiftURL: nil,
            swiftuiColorSwiftURL: colorsFile
        )
        
        let exporter = XcodeColorExporter(output: output)

        let result = try exporter.export(colorPairs: [colorPair1, colorPair2])
        XCTAssertEqual(result.count, 1)

        XCTAssertTrue(result[0].destination.url.absoluteString.hasSuffix("Colors.swift"))

        let content = result[0].data
        XCTAssertNotNil(content)

        try assertCodeEquals(content, """
        \(header)

        import SwiftUI

        private class BundleProvider {
            static let bundle = Bundle(for: BundleProvider.self)
        }

        public extension ShapeStyle where Self == Color {
            static var colorPair1: Color { Color(red: 1.000, green: 1.000, blue: 1.000, opacity: 1.000) }
            static var colorPair2: Color { Color(red: 0.467, green: 0.012, blue: 1.000, opacity: 0.500) }
        }

        """)
    }
}

fileprivate func assertCodeEquals(_ data: Data?, _ referenceCode: String) throws {
    let data = try XCTUnwrap(data)
    let generatedCode = String(data: data, encoding: .utf8)
    XCTAssertNoDifference(generatedCode, referenceCode)
}
