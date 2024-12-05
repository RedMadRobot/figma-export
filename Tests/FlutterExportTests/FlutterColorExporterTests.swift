import Foundation
import XCTest
import FigmaExportCore
import CustomDump
import Logging

@testable
import FlutterExport

final class FlutterColorExporterTests: XCTestCase {
    private let fileManager = FileManager.default
    private var colorsFile: URL!

    private let colorPair1 = AssetPair<Color>(
        light: Color(name: "colorPair1", red: 1, green: 1, blue: 1, alpha: 1),
        dark: Color(name: "colorPair1", red: 0, green: 0, blue: 0, alpha: 1)
    )

    private let colorPair2 = AssetPair<Color>(
        light: Color(name: "colorPair2", red: 153/255, green: 20/255, blue: 19/255, alpha: 1),
        dark: Color(name: "colorPair2", red: 123/255, green: 11/255, blue: 5/255, alpha: 1)
    )

    private let colorPair3 = AssetPair<Color>(
        light: Color(name: "colorPair3", red: 119.0/255.0, green: 3.0/255.0, blue: 1.0, alpha: 0.5),
        dark: nil
    )

    private let color3: Color = {
        var color = Color(name: "background/primary", red: 119.0/255.0, green: 3.0/255.0, blue: 1.0, alpha: 0.5)
        color.name = "backgroundPrimary"
        return color
    }()

    private lazy var colorPair4 = AssetPair<Color>(
        light: color3,
        dark: nil
    )

    private let colorWithKeyword = AssetPair<Color>(
        light: Color(name: "class", platform: .ios, red: 1, green: 1, blue: 1, alpha: 1),
        dark: nil
    )

    override func setUp() {
        colorsFile = fileManager.temporaryDirectory.appendingPathComponent("colors.dart")
    }

    func test_exportColors_generateVariationsAsProperties_true() throws {
        // Given
        let output = FlutterColorsOutput(
            generateVariationsAsProperties: true,
            colorsClassName: "Colors",
            outputURL: colorsFile,
            templatesURL: nil
        )
        let logger = Logger(label: "test")
        let exporter = FlutterColorExporter(output: output, logger: logger)

        // When
        let result = try exporter.export(colorPairs: [colorPair1, colorPair2])

        // Then
        XCTAssertEqual(result.count, 1)

        let content = result[0].data
        XCTAssertNotNil(content)

        try assertCodeEquals(content, """
        \(header)
        import 'package:flutter/material.dart';

        class Colors {
          final Color light;
          final Color dark;

          const Colors({
            required this.light,
            required this.dark,
          });

          static const colorPair1 = Colors(
            light: Color(0xFFFFFFFF),
            dark: Color(0xFF000000),
          );
          static const colorPair2 = Colors(
            light: Color(0xFF991413),
            dark: Color(0xFF7B0B05),
          );
        }

        """)
    }

    func test_exportColors_generateVariationsAsProperties_false() throws {
        // Given
        let output = FlutterColorsOutput(
            generateVariationsAsProperties: false,
            colorsClassName: "Colors",
            outputURL: colorsFile,
            templatesURL: nil
        )
        let logger = Logger(label: "test")
        let exporter = FlutterColorExporter(output: output, logger: logger)

        // When
        let result = try exporter.export(colorPairs: [colorPair1, colorPair2])

        // Then
        XCTAssertEqual(result.count, 1)

        let content = result[0].data
        XCTAssertNotNil(content)

        try assertCodeEquals(content, """
        \(header)
        import 'package:flutter/material.dart';

        class Colors {
          final Color value;

          const UiColors(this.value);

          static const colorPair1Light = Colors(
            Color(0xFFFFFFFF),
          );
          static const colorPair1Dark = Colors(
            Color(0xFF000000),
          );
          static const colorPair2Light = Colors(
            Color(0xFF991413),
          );
          static const colorPair2Dark = Colors(
            Color(0xFF7B0B05),
          );
        }

        """)
    }

    func test_exportColors_generateVariationsAsProperties_true_differentVariations() throws {
        // Given
        let output = FlutterColorsOutput(
            generateVariationsAsProperties: true,
            colorsClassName: "Colors",
            outputURL: colorsFile,
            templatesURL: nil
        )
        let logger = Logger(label: "test")
        let exporter = FlutterColorExporter(output: output, logger: logger)

        // When, Then
        XCTAssertThrowsError(try exporter.export(colorPairs: [colorPair1, colorPair3]))
    }

    func test_exportColors_generateVariationsAsProperties_true_isKeyword() throws {
        // Given
        let output = FlutterColorsOutput(
            generateVariationsAsProperties: true,
            colorsClassName: "Colors",
            outputURL: colorsFile,
            templatesURL: nil
        )
        let logger = Logger(label: "test")
        let exporter = FlutterColorExporter(output: output, logger: logger)

        // When
        let result = try exporter.export(colorPairs: [colorPair4, colorWithKeyword])

        // Then
        XCTAssertEqual(result.count, 1)

        let content = result[0].data
        XCTAssertNotNil(content)

        try assertCodeEquals(content, """
        \(header)
        import 'package:flutter/material.dart';

        class Colors {
          final Color light;

          const Colors({
            required this.light,
          });

          static const backgroundPrimary = Colors(
            light: Color(0x7F7703FF),
          );
        }

        """)
    }
}

private func assertCodeEquals(_ data: Data?, _ referenceCode: String) throws {
    let data = try XCTUnwrap(data)
    let generatedCode = String(data: data, encoding: .utf8)
    XCTAssertNoDifference(generatedCode, referenceCode)
}
