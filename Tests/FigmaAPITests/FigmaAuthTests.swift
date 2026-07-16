import XCTest
import Foundation
@testable import FigmaAPI

final class FigmaAuthTests: XCTestCase {

    func testPersonalTokenAssociatedValue() {
        let auth = FigmaAuth.personalToken("test-pat-token")
        if case .personalToken(let token) = auth {
            XCTAssertEqual(token, "test-pat-token")
        } else {
            XCTFail("Expected personalToken case")
        }
    }

    func testOAuthAssociatedValue() {
        let auth = FigmaAuth.oauth("test-oauth-token")
        if case .oauth(let token) = auth {
            XCTAssertEqual(token, "test-oauth-token")
        } else {
            XCTFail("Expected oauth case")
        }
    }

    func testPersonalTokenIsNotOAuth() {
        let auth = FigmaAuth.personalToken("token")
        if case .oauth = auth {
            XCTFail("personalToken should not match oauth case")
        }
    }

    func testOAuthIsNotPersonalToken() {
        let auth = FigmaAuth.oauth("token")
        if case .personalToken = auth {
            XCTFail("oauth should not match personalToken case")
        }
    }
}
