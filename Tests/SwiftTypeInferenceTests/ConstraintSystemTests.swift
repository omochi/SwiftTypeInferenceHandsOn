import XCTest
import SwiftcSema

final class ConstraintSystemTests: XCTestCase {
    func test1() {
        let cs = ConstraintSystem()
        cs.createTypeVariable()
        cs.dump()
    }
}
