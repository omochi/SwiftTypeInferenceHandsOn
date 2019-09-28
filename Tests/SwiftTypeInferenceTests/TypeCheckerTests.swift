import XCTest
import SwiftcTest

class TypeCheckerTests: XCTestCase {
    func testClosureExpr() throws {
        let s = try Parser(source: """
{ (x: Int) in
    x
}
"""
        ).parse()
        
        let cl1 = try XCTCast(XCTArrayGet(s.statements, 0), ClosureExpr.self)
        let _ = try XCTCast(XCTArrayGet(cl1.body, 0), UnresolvedDeclRefExpr.self)
        
        let tc = TypeChecker(source: s)
        try tc.typeCheck()
        
        let cl2 = try XCTCast(XCTArrayGet(s.statements, 0), ClosureExpr.self)
        let vd = cl2.parameter
        let dr = try XCTCast(XCTArrayGet(cl2.body, 0), DeclRefExpr.self)
        XCTAssertTrue(dr.target === vd)
    }
    
    func testClosureExprError() throws {
        let s = try Parser(source: """
{ (x) in
    x
}
"""
        ).parse()
        
        let tc = TypeChecker(source: s)
        XCTAssertThrowsError(try tc.typeCheck())
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
    
    func testClosureArgInfer() throws {
        let code = """
{ (x) -> Int in 4 }(3)
"""
        let s = try Parser(source: code).parse()
        
        let tc = TypeChecker(source: s)
        try tc.typeCheck()

        let ap = try XCTCast(XCTArrayGet(s.statements, 0), CallExpr.self)
        XCTAssertEqual(ap.type, PrimitiveType.int)
        
        let cl = try XCTCast(ap.callee, ClosureExpr.self)
        XCTAssertEqual(cl.type, FunctionType(parameter: PrimitiveType.int, result: PrimitiveType.int))
        
        XCTAssertEqual(cl.parameter.type, PrimitiveType.int)
        
        let ag = try XCTCast(ap.argument, IntegerLiteralExpr.self)
        XCTAssertEqual(ag.type, PrimitiveType.int)
    }
    
    func testClosureReturnInfer() throws {
        let code = """
{ (x) in x }(3)
"""
        let s = try Parser(source: code).parse()
        
        let tc = TypeChecker(source: s)
        try tc.typeCheck()

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
        let tc = TypeChecker(source: s)
        try tc.typeCheck()
    }
    
    func testAssignNoType() throws {
        let code = """
let a = 3
"""
        let s = try Parser(source: code).parse()
        let tc = TypeChecker(source: s)
        try tc.typeCheck()
        
        let vd = try XCTCast(XCTArrayGet(s.statements, 0), VariableDecl.self)
        XCTAssertEqual(vd.type, PrimitiveType.int)
    }
    
    func testAssignInt() throws {
        let code = """
let a: Int = 3
"""
        let s = try Parser(source: code).parse()
        let tc = TypeChecker(source: s)
        try tc.typeCheck()
        
        let vd = try XCTCast(XCTArrayGet(s.statements, 0), VariableDecl.self)
        XCTAssertEqual(vd.type, PrimitiveType.int)
    }
    
    func testAssignError() throws {
        let code = """
let a: String = 3
"""
        let s = try Parser(source: code).parse()
        let tc = TypeChecker(source: s)
        XCTAssertThrowsError(try tc.typeCheck())
    }
    
    func testArgConv() throws {
        // it does not generate conv typevar inference
        let s = try Parser(source: """
func f(a: Int?) { }
f(3)
"""
        ).parse()
        
        let tc = TypeChecker(source: s)
        try tc.typeCheck()
        
        let call = try XCTCast(XCTArrayGet(s.statements, 1), CallExpr.self)
        _ = try XCTCast(call.argument, InjectIntoOptionalExpr.self)
    }
    
    func testClosureConvBodyReturn() throws {
        let code = """
{ (x: Int) -> Int? in 4 }
"""
        let s = try Parser(source: code).parse()
        let tc = TypeChecker(source: s)
        try tc.typeCheck()
        
        let clr = try XCTCast(XCTArrayGet(s.statements, 0), ClosureExpr.self)
        _ = try XCTCast(XCTArrayGet(clr.body, 0), InjectIntoOptionalExpr.self)
    }
    
    func testAssignConv() throws {
        let code = """
let a: Int?? = 3
"""
        let s = try Parser(source: code).parse()
        let tc = TypeChecker(source: s)
        try tc.typeCheck()
        
        let vd = try XCTCast(XCTArrayGet(s.statements, 0), VariableDecl.self)

        let initializer = try XCTCast(XCTUnwrap(vd.initializer), InjectIntoOptionalExpr.self)
        _ = try XCTCast(initializer.subExpr, InjectIntoOptionalExpr.self)
    }
    
    func testArgConvAssignConvInfer() throws {
        let code = """
let a: Int? = { (x) in x }(3)
"""
        let s = try Parser(source: code).parse()
        let tc = TypeChecker(source: s)
        try tc.typeCheck()
        let vd = try XCTCast(XCTArrayGet(s.statements, 0), VariableDecl.self)
        
        // Actually there are multiple solutions
        // 1. (Int) -> Int
        // 2. (Int) -> Int?
        // 3. (Int?) -> Int?
        // but current implementation does not have stable logic.
        
        let iio = try XCTCast(XCTUnwrap(vd.initializer), InjectIntoOptionalExpr.self)
        let call = try XCTCast(iio.subExpr, CallExpr.self)
        let clr = try XCTCast(call.callee, ClosureExpr.self)
        XCTAssertEqual(try clr.typeOrThrow(),
                       FunctionType(parameter: PrimitiveType.int,
                                    result: PrimitiveType.int))
    }

}
