import XCTest
import AndroidExport
import FigmaExportCore

final class AndroidColorExporterTests: XCTestCase {
    
    // MARK: - Properties
    
    private let outputDirectory = URL(string: "~/")!
    
    private let colorPair1 = AssetPair<Color>(
        light: Color(name: "colorPair1", red: 119.0/255.0, green: 3.0/255.0, blue: 1.0, alpha: 0.5),
        dark: nil
    )
    
    private let colorPair2 = AssetPair<Color>(
        light: Color(name: "colorPair2", red: 1, green: 1, blue: 1, alpha: 1),
        dark: Color(name: "colorPair2", red: 0, green: 0, blue: 0, alpha: 1)
    )
    
    // MARK: - Setup
    
    func testExport() throws {
        let exporter = AndroidColorExporter(outputDirectory: outputDirectory)

        let result = exporter.export(colorPairs: [colorPair1, colorPair2])
        XCTAssertEqual(result.count, 2)

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
        <resources>
            <color name="colorPair1">#807703FF</color>
            <color name="colorPair2">#FFFFFF</color>
        </resources>
        """
        
        let referenceCodeDark = """
        <?xml version="1.0" encoding="utf-8"?>
        <resources>
            <color name="colorPair1">#807703FF</color>
            <color name="colorPair2">#000000</color>
        </resources>
        """
        
        XCTAssertEqual(generatedCodeLight, referenceCodeLight)
        XCTAssertEqual(generatedCodeDark, referenceCodeDark)
    }
}
