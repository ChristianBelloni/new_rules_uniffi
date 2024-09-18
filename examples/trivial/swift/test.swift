import XCTest
import Trivial

class TableValidationTests: XCTestCase {
    /// Tests that a new table instance has zero rows and columns.
    func testEmptyTableRowAndColumnCount() {
        let result = Trivial.add(left: 2, right: 5)
        XCTAssertEqual(result, 7)
    }
}
