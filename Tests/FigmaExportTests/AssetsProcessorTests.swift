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
}
