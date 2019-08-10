import XCTest
import SwiftTypeInference

//final class UnificationTests: XCTestCase {
//    var tvGen: TypeVariableGenerator!
//
//    var u: Unificator!
//    
//    override func setUp() {
//        u = Unificator()
//    }
//    
//    func unify(_ c: Constraint) throws {
//        try u.unify(constraint: c)
//    }
//    
//    func testIntInt() throws {
//        try unify(Constraint(left: IntType(), right: IntType()))
//    }
//    
//    func testIntString() throws {
//        XCTAssertThrowsError(
//            try self.unify(Constraint(left: IntType(), right: StringType()))
//        )
//    }
//    
//    func testVarInt() throws {
//        try unify(Constraint(left: TypeVariable(id: 1), right: IntType()))
//        assertEqualVariable(id: 1, type: IntType())
//    }
//    
//    func testIntVar() throws {
//        try unify(Constraint(left: IntType(), right: TypeVariable(id: 1)))
//        assertEqualVariable(id: 1, type: IntType())
//    }
//    
//    func testVarInt_VarString() throws {
//        try unify(Constraint(left: TypeVariable(id: 1), right: IntType()))
//        XCTAssertThrowsError(
//            try unify(Constraint(left: TypeVariable(id: 1), right: StringType()))
//        )
//    }
//    
//    func testVar1Int_Var1Var2() throws {
//        let v1 = TypeVariable(id: 1)
//        let v2 = TypeVariable(id: 2)
//        
//        try unify(Constraint(left: v1, right: IntType()))
//        try unify(Constraint(left: v1, right: v2))
//        
//        assertEqualVariable(id: 1, type: IntType())
//        assertEqualVariable(id: 2, type: IntType())
//    }
//    
//    func testVar1Int_Var2Var1() throws {
//        let v1 = TypeVariable(id: 1)
//        let v2 = TypeVariable(id: 2)
//        
//        try unify(Constraint(left: v1, right: IntType()))
//        try unify(Constraint(left: v2, right: v1))
//        
//        assertEqualVariable(id: 1, type: IntType())
//        assertEqualVariable(id: 2, type: IntType())
//    }
//    
//    func testVar1Var2_Var1Int() throws {
//        let v1 = TypeVariable(id: 1)
//        let v2 = TypeVariable(id: 2)
//        
//        try unify(Constraint(left: v1, right: v2))
//        try unify(Constraint(left: v1, right: IntType()))
//        
//        assertEqualVariable(id: 1, type: IntType())
//        assertEqualVariable(id: 2, type: IntType())
//    }
//    
//    func testFuncs() throws {
//        let v1 = TypeVariable(id: 1)
//        let f1 = FunctionType(arguments: [TypeVariable(id: 2)], result: TypeVariable(id: 3))
//        let f2 = FunctionType(arguments: [IntType()], result: TypeVariable(id: 4))
//        let f3 = FunctionType(arguments: [TypeVariable(id: 5)], result: StringType())
//        
//        try unify(Constraint(left: v1, right: f1))
//        try unify(Constraint(left: f1, right: f2))
//        try unify(Constraint(left: f2, right: f3))
//        
//        assertEqualVariable(id: 1, type: FunctionType(arguments: [IntType()], result: StringType()))
//        assertEqualVariable(id: 2, type: IntType())
//        assertEqualVariable(id: 3, type: StringType())
//        assertEqualVariable(id: 4, type: StringType())
//        assertEqualVariable(id: 5, type: IntType())
//    }
//    
//    private func assertEqualVariable(
//        id: Int,
//        type: Type,
//        file: StaticString = #file,
//        line: UInt = #line)
//    {
//        let subst = u.substitutions.items[TypeVariable(id: id)]
//        XCTAssertTrue(subst == type,
//                      file: file, line: line)
//    }
//}
