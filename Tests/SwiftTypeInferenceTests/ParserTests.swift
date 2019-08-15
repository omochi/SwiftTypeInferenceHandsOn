import XCTest
import SwiftcTest
import SwiftcType
import SwiftcAST

class ParserTests: XCTestCase {
    
    func testTopLetInit() throws {
        let pr = Parser(source: """
let a = 3
""")
        let s = try pr.parse()
        
        let v = try XCTCast(XCTArrayGet(s.topLevelCodes, 0), VariableDecl.self)
        let ie = try XCTCast(v.initializer, IntegerLiteralExpr.self)
        _ = ie
    }
    
    func testFunc() throws {
        let pr = Parser(source: """
func f(_ x: Int) { }
""")
        let s = try pr.parse()
        let f = try XCTCast(XCTArrayGet(s.functions, 0), FunctionDecl.self)
        XCTAssertEqual(f.parameterType, PrimitiveType.int)
        XCTAssertEqual(f.resultType, PrimitiveType.void)
    }
    
    func testCallClosure() throws {
        let pr = Parser(source: """
f({ (x) in x })
""")
        let s = try pr.parse()
        let ca = try XCTCast(XCTArrayGet(s.topLevelCodes, 0), CallExpr.self)
        let ud1 = try XCTCast(ca.callee, UnresolvedDeclRefExpr.self)
        XCTAssertEqual(ud1.name, "f")
        let cl = try XCTCast(ca.argument, ClosureExpr.self)
        XCTAssertEqual(cl.parameter.name, "x")
        XCTAssertNil(cl.parameter.typeAnnotation)
        let b = try XCTCast(XCTArrayGet(cl.body, 0), UnresolvedDeclRefExpr.self)
        XCTAssertEqual(b.name, "x")
    }
}
