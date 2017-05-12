import XCTest
@testable import Utilities

class FunctionsTests: XCTestCase {
    func testCommonElements() {
        XCTAssertEqual(
            commonElements(
                (0...5).map {$0},
                (0...5).map {$0},
                (0...5).map {$0}
            ),
            [0, 1, 2, 3, 4, 5]
        )
        XCTAssertEqual(
            commonElements(
                (0...3).map {$0},
                (4...6).map {$0},
                (0...6).map {$0}
            ),
            []
        )
        XCTAssertEqual(
            commonElements(
                (4...6).map {$0},
                (0...4).map {$0},
                (3...4).map {$0}
            ),
            [4]
        )
        XCTAssertEqual(
            commonElements(
                [[Int]]()
            ),
            []
        )
    }
}

extension FunctionsTests {
    static var allTests: [(String, (FunctionsTests) -> () throws -> Void)] {
        return [
            ("testCommonElements", testCommonElements),
        ]
    }
}
