import XCTest
import SwiftcTest

class TypeCheckerTests: XCTestCase {
    func testResolveDeclRef() throws  {
        let s = try Parser(source: """
{ (x) in
    x
}
"""
        ).parse()
        let tc = TypeChecker(source: s)
        try tc.resolveDeclRef()
        
        let cl = try XCTCast(XCTArrayGet(s.statements, 0), ClosureExpr.self)
        let vd = cl.parameter
        let dr = try XCTCast(XCTArrayGet(cl.body, 0), DeclRefExpr.self)
        XCTAssertTrue(dr.target === vd)
    }

}
