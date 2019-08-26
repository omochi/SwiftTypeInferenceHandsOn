import XCTest
import SwiftcTest

class ParserTests: XCTestCase {
    func testSourceLineMap() throws {
        do {
            let s = [
                "abc"
                ].joined()
            let m = SourceLineMap(source: s)
            XCTAssertEqual(m.offsets, [0])
        }
        do {
            let s = [
                "aaa\n",
                "bbb\r",
                "ccc\r\n",
                "ddd\n"
                ].joined()
            let m = SourceLineMap(source: s)
            XCTAssertEqual(m.offsets, [0, 4, 8, 13, 17])
            
            let l1 = SourcePosition(rawValue: 0).toLocation(name: nil, map: m)
            XCTAssertEqual(l1, SourceLocation(name: nil, line: 1, column: 1))
            
            let l2 = SourcePosition(rawValue: 5).toLocation(name: "a.swift", map: m)
            XCTAssertEqual(l2, SourceLocation(name: "a.swift", line: 2, column: 2))
            
            let l3 = SourcePosition(rawValue: 16).toLocation(name: nil, map: m)
            XCTAssertEqual(l3, SourceLocation(name: nil, line: 4, column: 4))
            
            let l4 = SourcePosition(rawValue: 17).toLocation(name: nil, map: m)
            XCTAssertEqual(l4, SourceLocation(name: nil, line: 5, column: 1))
            
            let l5 = SourcePosition(rawValue: 18).toLocation(name: nil, map: m)
            XCTAssertEqual(l5, SourceLocation(name: nil, line: 5, column: 2))
        }
    }
    
    func testTopLetInit() throws {
        let pr = Parser(source: """
let a = 3
""")
        let s = try pr.parse()
        
        let v = try XCTCast(XCTArrayGet(s.statements, 0), VariableDecl.self)
        let ie = try XCTCast(v.initializer, IntegerLiteralExpr.self)
        _ = ie
    }
    
    func testFunc() throws {
        let pr = Parser(source: """
func f(_ x: Int) { }
""")
        let s = try pr.parse()
        let f = try XCTCast(XCTArrayGet(s.statements, 0), FunctionDecl.self)
        XCTAssertEqual(f.parameterType, PrimitiveType.int)
        XCTAssertEqual(f.resultType, PrimitiveType.void)
    }
    
    func testCallClosure() throws {
        let pr = Parser(source: """
f({ (x) in x })
""")
        let s = try pr.parse()
        let ca = try XCTCast(XCTArrayGet(s.statements, 0), CallExpr.self)
        let ud1 = try XCTCast(ca.callee, UnresolvedDeclRefExpr.self)
        XCTAssertEqual(ud1.name, "f")
        let cl = try XCTCast(ca.argument, ClosureExpr.self)
        XCTAssertEqual(cl.parameter.name, "x")
        XCTAssertNil(cl.parameter.typeAnnotation)
        let b = try XCTCast(XCTArrayGet(cl.body, 0), UnresolvedDeclRefExpr.self)
        XCTAssertEqual(b.name, "x")
    }
}
