import XCTest
import AndroidExport
import FigmaExportCore
import CustomDump

final class AndroidColorExporterTests: XCTestCase {
    
    // MARK: - Properties
    
    private static let packageName = "test"
    private static let resourcePackage = "resourceTest"
    private let output = AndroidOutput(
        xmlOutputDirectory: URL(string: "~/")!,
        xmlResourcePackage: resourcePackage,
        srcDirectory: URL(string: "~/"),
        packageName: packageName,
        templatesPath: nil
    )
    
    private let colorPair1 = AssetPair<Color>(
        light: Color(name: "color_pair_1", red: 119.0/255.0, green: 3.0/255.0, blue: 1.0, alpha: 0.5),
        dark: nil
    )
    
    private let colorPair2 = AssetPair<Color>(
        light: Color(name: "color_pair_2", red: 1, green: 1, blue: 1, alpha: 1),
        dark: Color(name: "color_pair_2", red: 0, green: 0, blue: 0, alpha: 1)
    )
    
    // MARK: - Setup
    
    func testExport() throws {
        let exporter = AndroidColorExporter(output: output, xmlOutputFileName: nil)

        let result = try exporter.export(colorPairs: [colorPair1, colorPair2])
        XCTAssertEqual(result.count, 3)

        XCTAssertEqual(result[0].destination.directory.lastPathComponent, "values")
        XCTAssertEqual(result[0].destination.file.absoluteString, "colors.xml")
        
        XCTAssertEqual(result[1].destination.directory.lastPathComponent, "values-night")
        XCTAssertEqual(result[1].destination.file.absoluteString, "colors.xml")
        
        let fileContentLight = try XCTUnwrap(result[0].data)
        let fileContentDark = try XCTUnwrap(result[1].data)
        
        let generatedCodeLight = String(data: fileContentLight, encoding: .utf8)
        let generatedCodeDark = String(data: fileContentDark, encoding: .utf8)
        
        let referenceCodeLight = """
        <?xml version="1.0" encoding="utf-8"?>
        <!--
        \(header)
        -->
        <resources>
            <color name="color_pair_1">#807703FF</color>
            <color name="color_pair_2">#FFFFFF</color>
        </resources>

        """
        
        let referenceCodeDark = """
        <?xml version="1.0" encoding="utf-8"?>
        <!--
        \(header)
        -->
        <resources>
            <color name="color_pair_1">#807703FF</color>
            <color name="color_pair_2">#000000</color>
        </resources>

        """

        XCTAssertNoDifference(generatedCodeLight, referenceCodeLight)
        XCTAssertNoDifference(generatedCodeDark, referenceCodeDark)
        
        XCTAssertEqual(result[2].destination.directory.lastPathComponent, AndroidColorExporterTests.packageName)
        XCTAssertEqual(result[2].destination.file.absoluteString, "Colors.kt")
        let generatedComposedCode = String(data: try XCTUnwrap(result[2].data), encoding: .utf8)
        let referenceComposeCode = """
        /*
        \(header)
        */
        package \(AndroidColorExporterTests.packageName)
        
        import androidx.compose.runtime.Composable
        import androidx.compose.runtime.ReadOnlyComposable
        import androidx.compose.ui.graphics.Color
        import androidx.compose.ui.res.colorResource
        import \(AndroidColorExporterTests.resourcePackage).R
        
        object Colors
        
        @Composable
        @ReadOnlyComposable
        fun Colors.colorPair1(): Color = colorResource(id = R.color.color_pair_1)
        
        @Composable
        @ReadOnlyComposable
        fun Colors.colorPair2(): Color = colorResource(id = R.color.color_pair_2)

        """
        XCTAssertNoDifference(generatedComposedCode, referenceComposeCode)
    }
}
