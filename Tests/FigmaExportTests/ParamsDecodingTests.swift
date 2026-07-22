import XCTest
import Yams
@testable import FigmaExport

final class ParamsDecodingTests: XCTestCase {

    func testDecodeColorsExcludeList() throws {
        let yaml = """
        figma:
          lightFileId: file_id
        common:
          colors:
            exclude:
              - background
              - background/*
        """

        let params = try YAMLDecoder().decode(Params.self, from: yaml)

        XCTAssertEqual(params.common?.colors?.exclude, ["background", "background/*"])
    }

    func testDecodeVariablesColorsExcludeList() throws {
        let yaml = """
        figma:
          lightFileId: file_id
        common:
          variablesColors:
            tokensFileId: tokens_id
            tokensCollectionName: Base collection
            lightModeName: Light
            exclude:
              - background
              - backgroundSecondary
        """

        let params = try YAMLDecoder().decode(Params.self, from: yaml)

        XCTAssertEqual(params.common?.variablesColors?.exclude, ["background", "backgroundSecondary"])
    }

    func testDecodeWithoutExcludeList() throws {
        let yaml = """
        figma:
          lightFileId: file_id
        common:
          colors:
            nameValidateRegexp: '^([a-zA-Z_]+)$'
        """

        let params = try YAMLDecoder().decode(Params.self, from: yaml)

        XCTAssertNil(params.common?.colors?.exclude)
        XCTAssertNil(params.common?.variablesColors?.exclude)
    }
}
