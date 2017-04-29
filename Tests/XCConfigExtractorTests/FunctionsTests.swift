import XCTest

func commonElements<T: Hashable>(_ args: [T]...) -> [T] {
    return commonElements(args)
}
func commonElements<T: Hashable>(_ args: [[T]]) -> [T] {
    var fst: [T] = args[0]
    for i in (0..<fst.count).reversed() {
        for cur in args.dropFirst() {
            if fst.isEmpty {
                return fst
            }
            if cur.contains(fst[i]) == false {
                fst.remove(at: i)
                break // this breaks only inner loop
            }
        }
    }
    return fst
}

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
    }
}

extension FunctionsTests {
    static var allTests: [(String, (FunctionsTests) -> () throws -> Void)] {
        return [
            ("testCommonElements", testCommonElements),
        ]
    }
}
