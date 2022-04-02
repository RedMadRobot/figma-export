import XCTest
import FigmaExportCore

final class AssetsProcessorTests: XCTestCase {
    
    func testProcessCamelCase() throws {
        let images = [
            ImagePack(image: Image(name: "ic_24_icon", url: URL(string: "1")!, format: "pdf")),
            ImagePack(image: Image(name: "ic_24_icon_name", url: URL(string: "2")!, format: "pdf"))
        ]
        
        let processor = ImagesProcessor(
            platform: .ios,
            nameStyle: .camelCase
        )
        let icons = try processor.process(assets: images).get()
        
        XCTAssertEqual(
            icons.map { $0.name },
            ["ic24Icon", "ic24IconName"]
        )
    }
    
    func testProcessSnakeCase() throws {
        let images = [
            ImagePack(image: Image(name: "ic/24/Icon", url: URL(string: "1")!, format: "pdf")),
            ImagePack(image: Image(name: "ic/24/icon/name", url: URL(string: "2")!, format: "pdf")),
        ]
        
        let processor = ImagesProcessor(
            platform: .android,
            nameStyle: .snakeCase
        )
        let icons = try processor.process(assets: images).get()
        
        XCTAssertEqual(
            icons.map { $0.name },
            ["ic_24_icon", "ic_24_icon_name"]
        )
    }
    
    func testProcessWithValidateAndReplace() throws {
        let images = [
            ImagePack(image: Image(name: "ic_24_icon", url: URL(string: "1")!, format: "pdf")),
            ImagePack(image: Image(name: "ic_24_icon_name", url: URL(string: "2")!, format: "pdf")),
        ]
        
        let processor = ImagesProcessor(
            platform: .ios,
            nameValidateRegexp: #"^(ic)_(\d\d)_([a-z0-9_]+)$"#,
            nameReplaceRegexp: #"icon_$2_$3"#,
            nameStyle: .camelCase
        )
        let icons = try processor.process(assets: images).get()
        
        XCTAssertEqual(
            icons.map { $0.name },
            ["icon24Icon", "icon24IconName"]
        )
    }
    
    func testProcessWithReplaceImageNameInSnakeCase() throws {
        let images = [
            ImagePack(image: Image(name: "32 - Profile", url: URL(string: "1")!, format: "pdf"))
        ]
        
        let processor = ImagesProcessor(
            platform: .ios,
            nameValidateRegexp: "^(\\d\\d) - ([A-Za-z0-9 ]+)$",
            nameReplaceRegexp: #"icon_$2_$1"#,
            nameStyle: .snakeCase
        )
        let icons = try processor.process(assets: images).get()
        
        XCTAssertEqual(
            icons.map { $0.name },
            ["icon_profile_32"]
        )
    }
    
    func testProcessWithReplaceImageName() throws {
        let images = [
            ImagePack(image: Image(name: "32 - Profile", url: URL(string: "1")!, format: "pdf"))
        ]
        
        let processor = ImagesProcessor(
            platform: .ios,
            nameValidateRegexp: "^(\\d\\d) - ([A-Za-z0-9 ]+)$",
            nameReplaceRegexp: #"icon_$2_$1"#,
            nameStyle: .snakeCase
        )
        let icons = try processor.process(light: images, dark: nil).get()
        
        XCTAssertEqual(
            icons.map { $0.light.name },
            ["icon_profile_32"]
        )
    }
    
    func testProcessWithReplaceImageName2() throws {
        let images = [
            ImagePack(image: Image(name: "32 - Profile", url: URL(string: "1")!, format: "pdf"))
        ]
        
        let processor = ImagesProcessor(
            platform: .ios,
            nameValidateRegexp: "^(\\d\\d) - ([A-Za-z0-9 ]+)$",
            nameReplaceRegexp: #"icon_$2_$1"#,
            nameStyle: .snakeCase
        )
        let icons = try processor.process(light: images, dark: images).get()
        
        XCTAssertEqual(
            [icons.map { $0.light.name }, icons.map { $0.dark!.name }],
            [["icon_profile_32"], ["icon_profile_32"]]
        )
    }
    
    func testProcessWithReplaceForInvalidAsssetName() throws {
        let images = [
            ImagePack(image: Image(name: "ic24", url: URL(string: "1")!, format: "pdf"))
        ]
        
        let processor = ImagesProcessor(
            platform: .ios,
            nameValidateRegexp: #"^(ic)_(\d\d)_([a-z0-9_]+)$"#,
            nameReplaceRegexp: #"icon_$2_$3"#,
            nameStyle: .camelCase
        )
        
        XCTAssertThrowsError(try processor.process(assets: images).get())
    }
    
    // Light count can exceed dark count
    func testProcessWithUniversalAsset() throws {
        let lights = [
            Color(name: "primaryText", platform: .ios, red: 0, green: 0, blue: 0, alpha: 0),
            Color(name: "primaryLink", platform: .ios, red: 0, green: 0, blue: 0, alpha: 0)
        ]
        
        let darks = [
            Color(name: "primaryText", platform: .ios, red: 0, green: 0, blue: 0, alpha: 0)
        ]
        
        let processor = ColorsProcessor(
            platform: .ios,
            nameValidateRegexp: nil,
            nameReplaceRegexp: nil,
            nameStyle: .camelCase
        )
        let colors = try processor.process(light: lights, dark: darks).get()
        
        XCTAssertEqual(
            [colors.compactMap { $0.light.name }, colors.compactMap { $0.dark?.name }],
            [["primaryLink", "primaryText"], ["primaryText"]]
        )
    }
    
    // Dark count cannot exceed light count
    func testProcessWithUniversalAsset2() throws {
        let lights = [
            Color(name: "primaryText", platform: .ios, red: 0, green: 0, blue: 0, alpha: 0),
        ]
        
        let darks = [
            Color(name: "primaryText", platform: .ios, red: 0, green: 0, blue: 0, alpha: 0),
            Color(name: "primaryLink", platform: .ios, red: 0, green: 0, blue: 0, alpha: 0)
        ]
        
        let processor = ColorsProcessor(
            platform: .ios,
            nameValidateRegexp: nil,
            nameReplaceRegexp: nil,
            nameStyle: .camelCase
        )
        
        XCTAssertThrowsError(try processor.process(light: lights, dark: darks).get())
    }

    // Light count can exceed lightHC count
    func testProcessWithUniversalAsset3() throws {
        let lights = [
            Color(name: "primaryText", platform: .ios, red: 0, green: 0, blue: 0, alpha: 0),
            Color(name: "primaryLink", platform: .ios, red: 0, green: 0, blue: 0, alpha: 0)
        ]

        let lightHC = [
            Color(name: "primaryText", platform: .ios, red: 0, green: 0, blue: 0, alpha: 0)
        ]

        let processor = ColorsProcessor(
            platform: .ios,
            nameValidateRegexp: nil,
            nameReplaceRegexp: nil,
            nameStyle: .camelCase
        )
        let colors = try processor.process(light: lights, dark: nil, lightHC: lightHC).get()

        XCTAssertEqual(
            [colors.compactMap { $0.light.name }, colors.compactMap { $0.lightHC?.name }],
            [["primaryLink", "primaryText"], ["primaryText"]]
        )
    }

    // LightHC count cannot exceed light count
    func testProcessWithUniversalAsset4() throws {
        let lights = [
            Color(name: "primaryText", platform: .ios, red: 0, green: 0, blue: 0, alpha: 0),
            Color(name: "primaryLink", platform: .ios, red: 0, green: 0, blue: 0, alpha: 0)
        ]

        let lightHC = [
            Color(name: "primaryText", platform: .ios, red: 0, green: 0, blue: 0, alpha: 0),
            Color(name: "primaryLink", platform: .ios, red: 0, green: 0, blue: 0, alpha: 0),
            Color(name: "primaryIcon", platform: .ios, red: 0, green: 0, blue: 0, alpha: 0)
        ]

        let processor = ColorsProcessor(
            platform: .ios,
            nameValidateRegexp: nil,
            nameReplaceRegexp: nil,
            nameStyle: .camelCase
        )

        XCTAssertThrowsError(try processor.process(light: lights, dark: nil, lightHC: lightHC).get())
    }

    // LightHC count cannot exceed light count
    func testProcessWithUniversalAsset5() throws {
        let lights = [
            Color(name: "primaryText", platform: .ios, red: 0, green: 0, blue: 0, alpha: 0),
            Color(name: "primaryLink", platform: .ios, red: 0, green: 0, blue: 0, alpha: 0)
        ]

        let darks = [
            Color(name: "primaryText", platform: .ios, red: 0, green: 0, blue: 0, alpha: 0),
            Color(name: "primaryLink", platform: .ios, red: 0, green: 0, blue: 0, alpha: 0)
        ]

        let lightsHC = [
            Color(name: "primaryText", platform: .ios, red: 0, green: 0, blue: 0, alpha: 0),
            Color(name: "primaryLink", platform: .ios, red: 0, green: 0, blue: 0, alpha: 0),
            Color(name: "primaryIcon", platform: .ios, red: 0, green: 0, blue: 0, alpha: 0)
        ]

        let processor = ColorsProcessor(
            platform: .ios,
            nameValidateRegexp: nil,
            nameReplaceRegexp: nil,
            nameStyle: .camelCase
        )

        XCTAssertThrowsError(try processor.process(light: lights, dark: darks, lightHC: lightsHC).get())
    }

    // DarkHC count cannot exceed lightHC count
    func testProcessWithUniversalAsset6() throws {
        let lights = [
            Color(name: "primaryText", platform: .ios, red: 0, green: 0, blue: 0, alpha: 0),
            Color(name: "primaryLink", platform: .ios, red: 0, green: 0, blue: 0, alpha: 0)
        ]

        let darks = [
            Color(name: "primaryText", platform: .ios, red: 0, green: 0, blue: 0, alpha: 0),
            Color(name: "primaryLink", platform: .ios, red: 0, green: 0, blue: 0, alpha: 0)
        ]

        let lightsHC = [
            Color(name: "primaryText", platform: .ios, red: 0, green: 0, blue: 0, alpha: 0),
            Color(name: "primaryLink", platform: .ios, red: 0, green: 0, blue: 0, alpha: 0)
        ]

        let darksHC = [
            Color(name: "primaryText", platform: .ios, red: 0, green: 0, blue: 0, alpha: 0),
            Color(name: "primaryLink", platform: .ios, red: 0, green: 0, blue: 0, alpha: 0),
            Color(name: "primaryIcon", platform: .ios, red: 0, green: 0, blue: 0, alpha: 0)
        ]

        let processor = ColorsProcessor(
            platform: .ios,
            nameValidateRegexp: nil,
            nameReplaceRegexp: nil,
            nameStyle: .camelCase
        )

        XCTAssertThrowsError(try processor.process(light: lights, dark: darks, lightHC: lightsHC, darkHC: darksHC).get())
    }

    // Light count can exceed dark, lightHC and darkHC count
    func testProcessWithUniversalAsset7() throws {
        let lights = [
            Color(name: "primaryText", platform: .ios, red: 0, green: 0, blue: 0, alpha: 0),
            Color(name: "primaryLink", platform: .ios, red: 0, green: 0, blue: 0, alpha: 0),
            Color(name: "primaryIcon", platform: .ios, red: 0, green: 0, blue: 0, alpha: 0)
        ]

        let darks = [
            Color(name: "primaryText", platform: .ios, red: 0, green: 0, blue: 0, alpha: 0),
            Color(name: "primaryLink", platform: .ios, red: 0, green: 0, blue: 0, alpha: 0)
        ]

        let lightHC = [
            Color(name: "primaryText", platform: .ios, red: 0, green: 0, blue: 0, alpha: 0),
            Color(name: "primaryLink", platform: .ios, red: 0, green: 0, blue: 0, alpha: 0)
        ]

        let darkHC = [
            Color(name: "primaryText", platform: .ios, red: 0, green: 0, blue: 0, alpha: 0)
        ]

        let processor = ColorsProcessor(
            platform: .ios,
            nameValidateRegexp: nil,
            nameReplaceRegexp: nil,
            nameStyle: .camelCase
        )
        let colors = try processor.process(light: lights, dark: darks, lightHC: lightHC, darkHC: darkHC).get()

        XCTAssertEqual(
            [colors.compactMap { $0.light.name }, colors.compactMap { $0.dark?.name }, colors.compactMap { $0.lightHC?.name }, colors.compactMap { $0.darkHC?.name }],
            [["primaryIcon", "primaryLink", "primaryText"], ["primaryLink", "primaryText"], ["primaryLink", "primaryText"], ["primaryText"]]
        )
    }
    
    func testProcess() throws {
        let images = [
            ImagePack(image: Image(name: "icons / 24 / arrow back", url: URL(string: "/")!, format: "png"), platform: .android)
        ]
        
        let processor = ImagesProcessor(
            platform: .android,
            nameValidateRegexp: #"^icons _ (\d\d) _ ([A-Za-z0-9 /_-]+)$"#,
            nameReplaceRegexp: #"n2_icon_$2_$1"#,
            nameStyle: .snakeCase
        )
        
        let result = processor.process(assets: images)
        
        let extracted = try result.get()
        
        XCTAssertEqual(extracted[0].name, "n2_icon_arrow_back_24")
    }
}
