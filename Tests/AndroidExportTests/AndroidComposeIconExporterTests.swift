import XCTest
import AndroidExport
import FigmaExportCore
import CustomDump

final class AndroidComposeIconExporterTests: XCTestCase {
    
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
    
    private let iconName1 = "test_icon_1"
    private let iconName2 = "test_icon_2"
    
    // MARK: - Setup
    
    func testExport() throws {
        let exporter = AndroidComposeIconExporter(output: output)

        let result = try XCTUnwrap(exporter.exportIcons(iconNames: [iconName1, iconName2]))
        
        XCTAssertEqual(result.destination.directory.lastPathComponent, AndroidComposeIconExporterTests.packageName)
        XCTAssertEqual(result.destination.file.absoluteString, "Icons.kt")
        let generatedComposedCode = String(data: try XCTUnwrap(result.data), encoding: .utf8)
        let referenceComposeCode = """
        /*
        \(header)
        */
        package \(AndroidComposeIconExporterTests.packageName)
        
        import androidx.compose.material.Icon
        import androidx.compose.material.LocalContentAlpha
        import androidx.compose.material.LocalContentColor
        import androidx.compose.runtime.Composable
        import androidx.compose.ui.Modifier
        import androidx.compose.ui.graphics.Color
        import androidx.compose.ui.res.painterResource
        import \(AndroidComposeIconExporterTests.resourcePackage).R
        
        object Icons
        
        @Composable
        fun Icons.TestIcon1(
            contentDescription: String? = null,
            modifier: Modifier = Modifier,
            tint: Color = Color.Unspecified
        ) {
            Icon(
                painter = painterResource(id = R.drawable.test_icon_1),
                contentDescription = contentDescription,
                modifier = modifier,
                tint = tint
            )
        }
        
        @Composable
        fun Icons.TestIcon2(
            contentDescription: String? = null,
            modifier: Modifier = Modifier,
            tint: Color = Color.Unspecified
        ) {
            Icon(
                painter = painterResource(id = R.drawable.test_icon_2),
                contentDescription = contentDescription,
                modifier = modifier,
                tint = tint
            )
        }
        
        """
        XCTAssertNoDifference(generatedComposedCode, referenceComposeCode)
    }
}
