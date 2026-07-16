import XCTest
import Foundation
@testable import FigmaAPI

final class VariablesTests: XCTestCase {

    func testLookupPrefersLocalOverRemoteWithSameName() throws {
        let localId = "VariableCollectionId:1:4"
        let remoteId = "VariableCollectionId:abc123def456/1:9"

        let collections: [String: VariableCollectionValue] = [
            localId: VariableCollectionValue(
                defaultModeId: "1:0",
                id: localId,
                name: "Colors",
                remote: false,
                modes: [Mode(modeId: "1:0", name: "Light")],
                variableIds: ["var1", "var2", "var3"]
            ),
            remoteId: VariableCollectionValue(
                defaultModeId: "1:0",
                id: remoteId,
                name: "Colors",
                remote: true,
                modes: [Mode(modeId: "1:0", name: "Light")],
                variableIds: ["var1"]
            )
        ]

        let match = collections.first(where: {
            $0.value.name == "Colors" && $0.value.remote != true
        })

        XCTAssertNotNil(match)
        XCTAssertEqual(match?.key, localId)
        XCTAssertEqual(match?.value.variableIds.count, 3)
    }
}
