import XCTest
import Foundation
@testable import FigmaExportCore

final class AssetsFilterTests: XCTestCase {

    func testSingleMatch() {
        let filter = AssetsFilter(filter: "ic/24/edit")

        XCTAssert(filter.match(name: "ic/24/edit"))
        XCTAssertFalse(filter.match(name: "ic/24/call"))
    }

    func testMultipleMatch() {
        let filter = AssetsFilter(filter: "ic/24/edit, ic/16/notification")

        XCTAssert(filter.match(name: "ic/24/edit"))
        XCTAssert(filter.match(name: "ic/16/notification"))

        XCTAssertFalse(filter.match(name: "ic/24/call"))
        XCTAssertFalse(filter.match(name: "ic/16/edit"))
    }

    #if !os(Linux)
    func testMatchWithAsterisk() {
        let filter = AssetsFilter(filter: "ic/24/*")

        XCTAssert(filter.match(name: "ic/24/call"))
        XCTAssert(filter.match(name: "ic/24/test/my"))

        XCTAssertFalse(filter.match(name: "ic/16/call"))
        XCTAssertFalse(filter.match(name: "img/24/edit"))
    }
    #endif
}
