import XCTest
@testable import CoreUI

final class PhoneDisplayFormatterTests: XCTestCase {
    func testFormat_tenDigits_usesDashes() {
        XCTAssertEqual(PhoneDisplayFormatter.format("5552223333"), "555-222-3333")
        XCTAssertEqual(PhoneDisplayFormatter.format("555-222-3333"), "555-222-3333")
    }

    func testFormat_sevenDigits_usesDashes() {
        XCTAssertEqual(PhoneDisplayFormatter.format("5550101"), "555-0101")
        XCTAssertEqual(PhoneDisplayFormatter.format("555-0101"), "555-0101")
    }

    func testFormat_otherLengths_passthrough() {
        XCTAssertEqual(PhoneDisplayFormatter.format("123"), "123")
        XCTAssertEqual(PhoneDisplayFormatter.format("call me"), "call me")
    }
}
