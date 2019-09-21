import XCTest
import SwiftcTest

class TypeTests: XCTestCase {
    func testJoin() throws {
        let int = PrimitiveType.int
        let str = PrimitiveType.string
        let any = TopAnyType()
        XCTAssertEqual(int.join(int), int)
        XCTAssertEqual(int.join(str), any)
        XCTAssertEqual(OptionalType(int).join(int), OptionalType(int))
        XCTAssertEqual(int.join(OptionalType(int)), OptionalType(int))
        XCTAssertEqual(OptionalType(int).join(OptionalType(int)), OptionalType(int))
        XCTAssertEqual(OptionalType(int).join(OptionalType(str)), OptionalType(any))
        XCTAssertEqual(OptionalType(int).join(any), OptionalType(any))
        XCTAssertEqual(any.join(OptionalType(int)), OptionalType(any))
    }
    
}
