import XCTest
import AndroidExport
import FigmaExportCore

final class AndroidTypographyExporterTests: XCTestCase {
    
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
    
    private let textStyle1 = TextStyle(name: "title", fontName: "Test-Font", fontSize: 20.0, fontStyle: nil, letterSpacing: 0.25)
    private let textStyle2 = TextStyle(name: "subtitle", platform: nil, fontName: "Test-Font", fontSize: 19.5, fontStyle: nil, lineHeight: 20.0, letterSpacing: 0, textCase: TextStyle.TextCase.original)
    
    // MARK: - Setup
    
    func testExport() throws {
        let exporter = AndroidTypographyExporter(output: output)

        let result = try exporter.exportFonts(textStyles: [textStyle1, textStyle2])
        XCTAssertEqual(result.count, 2)

        XCTAssertEqual(result[0].destination.directory.lastPathComponent, "values")
        XCTAssertEqual(result[0].destination.file.absoluteString, "typography.xml")
        
        let fileContent = try XCTUnwrap(result[0].data)
        
        let generatedCode = String(data: fileContent, encoding: .utf8)
        let referenceCode = """
        <?xml version="1.0" encoding="utf-8"?>
        <resources>
            <style name="title">
                <item name="android:fontFamily">@font/test_font</item>
                <item name="android:textSize">20.0sp</item>
                <item name="android:letterSpacing">0.01</item>
            </style>
            <style name="subtitle">
                <item name="android:fontFamily">@font/test_font</item>
                <item name="android:textSize">19.5sp</item>
                <item name="android:letterSpacing">0.00</item>
            </style>
        </resources>
        """
        XCTAssertEqual(generatedCode, referenceCode)
        
        XCTAssertEqual(result[1].destination.directory.lastPathComponent, AndroidTypographyExporterTests.packageName)
        XCTAssertEqual(result[1].destination.file.absoluteString, "Typography.kt")
        let generatedComposedCode = String(data: try XCTUnwrap(result[1].data), encoding: .utf8)
        let referenceComposeCode = """
        package \(AndroidTypographyExporterTests.packageName)
        
        import androidx.compose.ui.text.TextStyle
        import androidx.compose.ui.text.font.Font
        import androidx.compose.ui.text.font.FontFamily
        import androidx.compose.ui.unit.sp
        import \(AndroidTypographyExporterTests.resourcePackage).R
        
        object Typography {
        
            val title = TextStyle(
                fontFamily = FontFamily(Font(R.font.test_font)),
                fontSize = 20.0.sp,
                letterSpacing = 0.25.sp,
            )
            val subtitle = TextStyle(
                fontFamily = FontFamily(Font(R.font.test_font)),
                fontSize = 19.5.sp,
                letterSpacing = 0.0.sp,
                lineHeight = 20.0.sp,
            )
        }
        
        """
        XCTAssertEqual(generatedComposedCode, referenceComposeCode)
    }
}
