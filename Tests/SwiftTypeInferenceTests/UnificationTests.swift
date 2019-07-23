import XCTest
import SwiftTypeInference

final class UnificationTests: XCTestCase {
    var tvGen: TypeVariableGenerator!

    var u: Unificator!
    
    override func setUp() {
        u = Unificator()
    }
    
    func testIntInt() throws {
        try u.unify(constraint: Constraint(left: IntType(), right: IntType()))
    }
    
    func testIntString() throws {
        XCTAssertThrowsError(
            try self.u.unify(constraint: Constraint(left: IntType(), right: StringType()))
        )
    }
    
    func testVarInt() throws {
        let v = TypeVariable(id: 1)
        let int = IntType()
        try u.unify(constraint: Constraint(left: v, right: int))
        XCTAssertEqual(u.substitutions[v], int.asAnyType())
    }
    
    func testIntVar() throws {
        let v = TypeVariable(id: 1)
        let int = IntType()
        try u.unify(constraint: Constraint(left: int, right: v))
        XCTAssertEqual(u.substitutions[v], int.asAnyType())
    }
    
    func testVarInt_VarString() throws {
        let v = TypeVariable(id: 1)
        
        try u.unify(constraint: Constraint(left: v, right: IntType()))
        XCTAssertThrowsError(
            try u.unify(constraint: Constraint(left: v, right: StringType()))
        )
    }
    
    func testVar1Int_Var1Var2() throws {
        let v1 = TypeVariable(id: 1)
        let v2 = TypeVariable(id: 2)
        
        try u.unify(constraint: Constraint(left: v1, right: IntType()))
        try u.unify(constraint: Constraint(left: v1, right: v2))
        
        XCTAssertEqual(u.substitutions[v1], IntType().asAnyType())
        XCTAssertEqual(u.substitutions[v2], IntType().asAnyType())
    }
    
    func testVar1Int_Var2Var1() throws {
        let v1 = TypeVariable(id: 1)
        let v2 = TypeVariable(id: 2)
        
        try u.unify(constraint: Constraint(left: v1, right: IntType()))
        try u.unify(constraint: Constraint(left: v2, right: v1))
        
        XCTAssertEqual(u.substitutions[v1], IntType().asAnyType())
        XCTAssertEqual(u.substitutions[v2], IntType().asAnyType())
    }
    
    func testVar1Var2_Var1Int() throws {
        let v1 = TypeVariable(id: 1)
        let v2 = TypeVariable(id: 2)
        
        try u.unify(constraint: Constraint(left: v1, right: v2))
        try u.unify(constraint: Constraint(left: v1, right: IntType()))
        
        XCTAssertEqual(u.substitutions[v1], IntType().asAnyType())
        XCTAssertEqual(u.substitutions[v2], IntType().asAnyType())
    }
}
