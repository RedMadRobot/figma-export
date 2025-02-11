import XCTest
import FigmaExportCore
import CustomDump

@testable import FlutterExport

final class FlutterIconsExporterTests: XCTestCase {
    private let fileManager = FileManager.default
    private var iconsOutputFile: URL!

    private lazy var lightImage: Image = Image(
        name: "iconPair1",
        url: URL(string: "https://example.com/light_icon.svg")!,
        format: "svg"
    )
    private lazy var darkImage: Image = Image(
        name: "iconPair1",
        url: URL(string: "https://example.com/dark_icon.svg")!,
        format: "svg"
    )

    private lazy var validLightPack: ImagePack = ImagePack(
        name: "iconPair1",
        images: [lightImage]
    )
    private lazy var validDarkPack: ImagePack = ImagePack(
        name: "iconPair1",
        images: [darkImage]
    )

    private lazy var iconPair1 = AssetPair<ImagePack>(
        light: validLightPack,
        dark: validDarkPack
    )

    private lazy var iconPairMissingDark = AssetPair<ImagePack>(
        light: validLightPack,
        dark: nil
    )

    private lazy var iconWithInvalidName: AssetPair<ImagePack> = {
        let invalidImage = Image(
            name: "class",
            url: URL(string: "https://example.com/light_icon.svg")!,
            format: "svg"
        )
        let invalidPack = ImagePack(name: "class", images: [invalidImage])
        return AssetPair<ImagePack>(
            light: invalidPack,
            dark: nil
        )
    }()

    override func setUp() {
        super.setUp()
        iconsOutputFile = fileManager.temporaryDirectory.appendingPathComponent("icons.dart")
    }

    func test_exportIcons_success() throws {
        // Given: A valid FlutterIconsOutput configuration.
        let output = FlutterIconsOutput(
            iconsAssetsFolder: URL(string: "assets/icons/my_icons")!,
            outputFile: iconsOutputFile,
            iconsClassName: "MyIcons",
            baseAssetClass: "IconAsset",
            baseAssetClassFilePath: "icon_asset.dart",
            relativeIconsPath: URL(string: "icons/")!,
            useSvgVec: false,
            templatesURL: nil
        )
        let exporter = FlutterIconsExporter(output: output)

        // When: Exporting an icon pair with both light and dark variants.
        let result = try exporter.export(icons: [iconPair1])

        // Then:
        XCTAssertEqual(result.files.count, 3)
        XCTAssertEqual(result.warnings.all.count, 0)

        let expectedSource = """
        \(header)
        import 'icon_asset.dart';

        class MyIcons {
          const MyIcons();

          final iconPair1 = const IconAsset(
            light: 'icons/icon_pair_1_light.svg',
            dark: 'icons/icon_pair_1_dark.svg',
          );
        }

        """
        let sourceFile = result.files.last!
        try assertCodeEquals(sourceFile.data, expectedSource)
    }

    func test_exportIcons_warningForInvalidName() throws {
        // Given: A valid FlutterIconsOutput configuration.
        let output = FlutterIconsOutput(
            iconsAssetsFolder: URL(string: "assets/icons/my_icons")!,
            outputFile: iconsOutputFile,
            iconsClassName: "MyIcons",
            baseAssetClass: "IconAsset",
            baseAssetClassFilePath: "icon_asset.dart",
            relativeIconsPath: URL(string: "icons/")!,
            useSvgVec: false,
            templatesURL: nil
        )
        let exporter = FlutterIconsExporter(output: output)

        // When: Exporting an asset pair with an invalid name.
        let result = try exporter.export(icons: [iconWithInvalidName])

        // Then:
        XCTAssertEqual(result.files.count, 1)
        XCTAssertEqual(result.warnings.all.count, 1)

        let expectedSource = """
        \(header)
        import 'icon_asset.dart';

        class MyIcons {
          const MyIcons();

        }

        """
        let sourceFile = result.files.first!
        try assertCodeEquals(sourceFile.data, expectedSource)
    }

    func test_exportIcons_incompleteVariations() throws {
        // Given
        let output = FlutterIconsOutput(
            iconsAssetsFolder: URL(string: "assets/icons/my_icons")!,
            outputFile: iconsOutputFile,
            iconsClassName: "MyIcons",
            baseAssetClass: "IconAsset",
            baseAssetClassFilePath: "icon_asset.dart",
            relativeIconsPath: URL(string: "icons/")!,
            templatesURL: nil
        )
        let exporter = FlutterIconsExporter(output: output)
        let completeAssetPair = iconPair1
        let incompleteAssetPair = iconPairMissingDark

        // When
        let result = try exporter.export(icons: [completeAssetPair, incompleteAssetPair])

        // Then
        let expectedSource = """
        \(header)
        import 'icon_asset.dart';

        class MyIcons {
          const MyIcons();

          final iconPair1 = const IconAsset(
            light: 'icons/icon_pair_1_light.svg',
            dark: 'icons/icon_pair_1_dark.svg',
          );
          final iconPair1 = const IconAsset(
            light: 'icons/icon_pair_1_light.svg',
            dark: null,
          );
        }

        """
        let sourceFile = result.files.last!
        try assertCodeEquals(sourceFile.data, expectedSource)
    }
}

private func assertCodeEquals(_ data: Data?, _ referenceCode: String) throws {
    let data = try XCTUnwrap(data)
    let generatedCode = String(data: data, encoding: .utf8)
    XCTAssertNoDifference(generatedCode, referenceCode)
}
