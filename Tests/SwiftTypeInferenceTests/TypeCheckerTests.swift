import XCTest
import SwiftcTest

class TypeCheckerTests: XCTestCase {
    func testResolveDeclRef() throws {
        let s = try Parser(source: """
{ (x) in
    x
}
"""
        ).parse()
        
        let cl1 = try XCTCast(XCTArrayGet(s.statements, 0), ClosureExpr.self)
        let _ = try XCTCast(XCTArrayGet(cl1.body, 0), UnresolvedDeclRefExpr.self)
        
        let tc = TypeChecker(source: s)
        let cl2 = try tc.resolveDeclRef(expr: cl1, context: s) as! ClosureExpr

        let vd = cl2.parameter
        let dr = try XCTCast(XCTArrayGet(cl2.body, 0), DeclRefExpr.self)
        XCTAssertTrue(dr.target === vd)
    }
    
    func testFunctionApplication() throws {
        let s = try Parser(source: """
func f(a: Int) -> String { }
f(3)
"""
        ).parse()
        
        let ca1 = try XCTCast(XCTArrayGet(s.statements, 1), CallExpr.self)
        XCTAssertNil(ca1.type)
        
        let tc = TypeChecker(source: s)
        try tc.typeCheck()
        
        let ca2 = try XCTCast(XCTArrayGet(s.statements, 1), CallExpr.self)
        XCTAssertEqual(ca2.type, PrimitiveType.string)
    }
    
    func testClosureCall() throws {
        let code = """
{ (x) in x }(3)
"""
        let s = try Parser(source: code).parse()
        
        s.dump(source: s)
        
        let tc = TypeChecker(source: s)
        try tc.typeCheck()
        s.dump(source: s)
        let ap = try XCTCast(XCTArrayGet(s.statements, 0), CallExpr.self)
        XCTAssertEqual(ap.type, PrimitiveType.int)
        
        let cl = try XCTCast(ap.callee, ClosureExpr.self)
        XCTAssertEqual(cl.type, FunctionType(parameter: PrimitiveType.int, result: PrimitiveType.int))
        
        XCTAssertEqual(cl.parameter.type, PrimitiveType.int)
        
        let ag = try XCTCast(ap.argument, IntegerLiteralExpr.self)
        XCTAssertEqual(ag.type, PrimitiveType.int)
    }
    
    func testOverload() throws {
        let code = """
func f(_ a: Int) { }
func f(_ a: String) { }
f(3)
"""
        let s = try Parser(source: code).parse()
        dump(s)
        let tc = TypeChecker(source: s)
        try tc.typeCheck()
    }

}
