import XCTest
import FigmaExportCore
import CustomDump

@testable import FlutterExport

final class FlutterImagesExporterTests: XCTestCase {
    private let fileManager = FileManager.default
    private var imagesOutputFile: URL!

    private lazy var lightImage: Image = Image(
        name: "imagePair1",
        url: URL(string: "https://example.com/light_image.png")!,
        format: "png"
    )
    private lazy var darkImage: Image = Image(
        name: "imagePair1",
        url: URL(string: "https://example.com/dark_image.png")!,
        format: "png"
    )

    private lazy var validLightPack: ImagePack = ImagePack(
        name: "imagePair1",
        images: [lightImage]
    )
    private lazy var validDarkPack: ImagePack = ImagePack(
        name: "imagePair1",
        images: [darkImage]
    )

    private lazy var imagePair1 = AssetPair<ImagePack>(
        light: validLightPack,
        dark: validDarkPack
    )

    private lazy var imagePairMissingDark = AssetPair<ImagePack>(
        light: validLightPack,
        dark: nil
    )

    private lazy var imageWithInvalidName: AssetPair<ImagePack> = {
        let invalidImage = Image(
            name: "class",
            url: URL(string: "https://example.com/light_image.png")!,
            format: "png"
        )
        let invalidPack = ImagePack(name: "class", images: [invalidImage])
        return AssetPair<ImagePack>(
            light: invalidPack,
            dark: nil
        )
    }()

    override func setUp() {
        super.setUp()
        imagesOutputFile = fileManager.temporaryDirectory.appendingPathComponent("images.dart")
    }

    func test_exportImages_success() throws {
        // Given: A valid FlutterImagesOutput configuration.
        let output = FlutterImagesOutput(
            imagesAssetsFolder: URL(string: "assets/images/my_images")!,
            outputFile: imagesOutputFile,
            imagesClassName: "MyImages",
            baseAssetClass: "ImageAsset",
            baseAssetClassFilePath: "image_asset.dart",
            relativeImagesPath: URL(string: "images/")!,
            format: "png",
            scales: [1.0, 2.0, 3.0],
            templatesURL: nil
        )
        let exporter = FlutterImagesExporter(output: output)

        // When: Exporting an image pair with both light and dark variants.
        let result = try exporter.export(images: [imagePair1])

        // Then:
        XCTAssertEqual(result.files.count, 3)
        XCTAssertEqual(result.warnings.all.count, 0)

        let expectedSource = """
        \(header)
        import 'image_asset.dart';

        class MyImages {
          const MyImages();

          final imagePair1 = const ImageAsset(
            light: 'images/image_pair_1_light.png',
            dark: 'images/image_pair_1_dark.png',
          );
        }

        """
        let sourceFile = result.files.last!
        try assertCodeEquals(sourceFile.data, expectedSource)
    }

    func test_exportImages_warningForInvalidName() throws {
        // Given: A valid FlutterImagesOutput configuration.
        let output = FlutterImagesOutput(
            imagesAssetsFolder: URL(string: "assets/images/my_images")!,
            outputFile: imagesOutputFile,
            imagesClassName: "MyImages",
            baseAssetClass: "ImageAsset",
            baseAssetClassFilePath: "image_asset.dart",
            relativeImagesPath: URL(string: "images/")!,
            format: "png",
            scales: [1.0, 2.0, 3.0],
            templatesURL: nil
        )
        let exporter = FlutterImagesExporter(output: output)

        // When: Exporting an asset pair with an invalid name.
        let result = try exporter.export(images: [imageWithInvalidName])

        // Then:
        XCTAssertEqual(result.files.count, 1)
        XCTAssertEqual(result.warnings.all.count, 1)

        let expectedSource = """
        \(header)
        import 'image_asset.dart';

        class MyImages {
          const MyImages();

        }

        """
        let sourceFile = result.files.first!
        try assertCodeEquals(sourceFile.data, expectedSource)
    }

    func test_exportImages_warningForMissingVariation() throws {
        // Given: A valid asset pair with both variants and an asset pair missing the dark variant.
        let output = FlutterImagesOutput(
            imagesAssetsFolder: URL(string: "assets/images/my_images")!,
            outputFile: imagesOutputFile,
            imagesClassName: "MyImages",
            baseAssetClass: "ImageAsset",
            baseAssetClassFilePath: "image_asset.dart",
            relativeImagesPath: URL(string: "images/")!,
            format: "png",
            scales: [1.0, 2.0, 3.0],
            templatesURL: nil
        )
        let exporter = FlutterImagesExporter(output: output)

        // When: Exporting both asset pairs.
        let result = try exporter.export(images: [imagePair1, imagePairMissingDark])

        // Then:
        XCTAssertEqual(result.files.count, 3)
        XCTAssertEqual(result.warnings.all.count, 1)

        let expectedSource = """
        \(header)
        import 'image_asset.dart';

        class MyImages {
          const MyImages();

          final imagePair1 = const ImageAsset(
            light: 'images/image_pair_1_light.png',
            dark: 'images/image_pair_1_dark.png',
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
