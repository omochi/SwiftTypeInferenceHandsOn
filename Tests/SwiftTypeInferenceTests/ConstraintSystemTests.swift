import XCTest
import SwiftcTest

final class ConstraintSystemTests: XCTestCase {
    func testMerge1() {
        let cts = ConstraintSystem()
        let t1 = cts.createTypeVariable()
        let t2 = cts.createTypeVariable()
        cts.mergeEquivalence(type1: t1, type2: t2)
        XCTAssertEqual(cts.fixedOrRepresentative(for: t1), t1)
        XCTAssertEqual(cts.fixedOrRepresentative(for: t2), t1)
    }
    
    func testMerge2() {
        let cts = ConstraintSystem()
        let t1 = cts.createTypeVariable()
        let t2 = cts.createTypeVariable()
        cts.mergeEquivalence(type1: t2, type2: t1)
        XCTAssertEqual(cts.fixedOrRepresentative(for: t1), t1)
        XCTAssertEqual(cts.fixedOrRepresentative(for: t2), t1)
    }
    
    func testTypeTypeVariables() {
        let cs = ConstraintSystem()
        let t1 = cs.createTypeVariable()
        let t2 = cs.createTypeVariable()
        let t3 = cs.createTypeVariable()
        
        // (T1) -> (T2) -> (T3)
        let tf = FunctionType(parameter: t1,
                              result: FunctionType(parameter: t2,
                                                   result: t3))
        
        XCTAssertEqual(tf.typeVariables, [t1, t2, t3])
    }
    
    func testMatchVars() {
        let cs = ConstraintSystem()
        let t1 = cs.createTypeVariable()
        XCTAssertEqual(cs.simplify(type: t1), t1)
        
        let t2 = cs.createTypeVariable()
        XCTAssertEqual(cs.simplify(type: t2), t2)
        
        cs.addConstraint(kind: .bind, left: t1, right: t2)
        XCTAssertEqual(t2.equivalentTypeVariables(bindings: cs.bindings), [])
        
        XCTAssertEqual(cs.simplify(type: t1), t1)
        XCTAssertEqual(cs.simplify(type: t2), t1)
        XCTAssertEqual(t1.equivalentTypeVariables(bindings: cs.bindings), [t1, t2])
        
        let t3 = cs.createTypeVariable()
        cs.addConstraint(kind: .bind, left: t1, right: t3)
        XCTAssertEqual(cs.simplify(type: t3), t1)
        
        let t4 = cs.createTypeVariable()
        cs.addConstraint(kind: .bind, left: t2, right: t4)
        XCTAssertEqual(cs.simplify(type: t4), t1)
        
        let t5 = cs.createTypeVariable()
        let t6 = cs.createTypeVariable()
        cs.addConstraint(kind: .bind, left: t6, right: t5)
        XCTAssertEqual(cs.simplify(type: t5), t5)
        XCTAssertEqual(cs.simplify(type: t6), t5)
        
        cs.addConstraint(kind: .bind, left: t6, right: t2)
        XCTAssertEqual(cs.simplify(type: t5), t1)
        XCTAssertEqual(cs.simplify(type: t6), t1)
        XCTAssertEqual(t1.equivalentTypeVariables(bindings: cs.bindings), [t1, t2, t3, t4, t5, t6])
    }
    
    func testMatchVarInt() {
        let cs = ConstraintSystem()
        let t1 = cs.createTypeVariable()
        let ti = PrimitiveType.int
        
        cs.addConstraint(kind: .bind, left: t1, right: ti)
        XCTAssertEqual(cs.simplify(type: t1), ti)
    }
    
    func testMatchIntVar() {
        let cs = ConstraintSystem()
        let t1 = cs.createTypeVariable()
        let ti = PrimitiveType.int
        
        cs.addConstraint(kind: .bind, left: ti, right: t1)
        XCTAssertEqual(cs.simplify(type: t1), ti)
    }
    
    func testMatchIntInt() {
        let cs = ConstraintSystem()
        let ti = PrimitiveType.int
        
        cs.addConstraint(kind: .bind, left: ti, right: ti)
        XCTAssertNil(cs.failedConstraint)
    }
    
    func testMatchIntString() {
        let cs = ConstraintSystem()
        let ti = PrimitiveType.int
        let ts = PrimitiveType.string
        
        cs.addConstraint(kind: .bind, left: ti, right: ts)
        XCTAssertNotNil(cs.failedConstraint)
    }
    
    func testMatchIntString2() {
        let cs = ConstraintSystem()
        let t1 = cs.createTypeVariable()
        let t2 = cs.createTypeVariable()
        let ti = PrimitiveType.int
        let ts = PrimitiveType.string
        
        cs.addConstraint(kind: .bind, left: t1, right: ti)
        cs.addConstraint(kind: .bind, left: t2, right: ts)
        XCTAssertNil(cs.failedConstraint)
        
        cs.addConstraint(kind: .bind, left: t1, right: t2)
        XCTAssertNotNil(cs.failedConstraint)
        
        cs.dump()
    }
    
    func testMatchVarFunc1() {
        let cs = ConstraintSystem()
        let t1 = cs.createTypeVariable()
        let t2 = cs.createTypeVariable()
        let ti = PrimitiveType.int
        let ts = PrimitiveType.string
        
        // (T1) -> T2  :bind:  (Int) -> String
        cs.addConstraint(kind: .bind,
                         left: FunctionType(parameter: t1, result: t2),
                         right: FunctionType(parameter: ti, result: ts))
        XCTAssertEqual(cs.simplify(type: t1), ti)
        XCTAssertEqual(cs.simplify(type: t2), ts)
    }
    
    func testMatchVarFunc2() {
        let cs = ConstraintSystem()
        let t1 = cs.createTypeVariable()
        let t2 = cs.createTypeVariable()
        let t3 = cs.createTypeVariable()
        let ti = PrimitiveType.int
        let ts = PrimitiveType.string
        
        // T1              :bind:   (Int) -> T3
        cs.addConstraint(kind: .bind,
                         left: t1,
                         right: FunctionType(parameter: ti, result: t3))
        
        // (T2) -> String  :bind:   T1
        cs.addConstraint(kind: .bind,
                         left: FunctionType(parameter: t2, result: ts),
                         right: t1)
        
        XCTAssertEqual(cs.simplify(type: t1), FunctionType(parameter: ti, result: ts))
        XCTAssertEqual(cs.simplify(type: t2), ti)
        XCTAssertEqual(cs.simplify(type: t3), ts)
    }
    
    func testMatchVarFunc3() {
        let cs = ConstraintSystem()
        let t1 = cs.createTypeVariable()
        let t2 = cs.createTypeVariable()
        let t3 = cs.createTypeVariable()
        let t4 = cs.createTypeVariable()
        let t5 = cs.createTypeVariable()
        let ti = PrimitiveType.int
        let ts = PrimitiveType.string
        
        // T1 :bind: (T2) -> T3
        cs.addConstraint(kind: .bind, left: t1, right: FunctionType(parameter: t2, result: t3))
        
        // T4 :bind: (Int) -> Int
        cs.addConstraint(kind: .bind, left: t4, right: FunctionType(parameter: ti, result: ti))
        
        // T5 :bind: (String) -> String
        cs.addConstraint(kind: .bind, left: t5, right: FunctionType(parameter: ts, result: ts))
                
        // T2 :bind: T4
        cs.addConstraint(kind: .bind, left: t2, right: t4)
        
        // T3 :bind: T5
        cs.addConstraint(kind: .bind, left: t3, right: t5)

        XCTAssertEqual(cs.simplify(type: t1),
                       FunctionType(
                        parameter: FunctionType(parameter: ti, result: ti),
                        result: FunctionType(parameter: ts, result: ts))
        )
        
        XCTAssertEqual(cs.simplify(type: t2), FunctionType(parameter: ti, result: ti))
        XCTAssertEqual(cs.simplify(type: t3), FunctionType(parameter: ts, result: ts))
        XCTAssertEqual(cs.simplify(type: t4), FunctionType(parameter: ti, result: ti))
        XCTAssertEqual(cs.simplify(type: t5), FunctionType(parameter: ts, result: ts))
    }
    
    func testApplicableFunction1() {
        let cs = ConstraintSystem()
        
        let t1 = cs.createTypeVariable()
        let ti = PrimitiveType.int
        let ts = PrimitiveType.string
        
        cs.addConstraint(kind: .applicableFunction,
                         left: FunctionType(parameter: ti, result: t1),
                         right: FunctionType(parameter: ti, result: ts))
        
        XCTAssertNil(cs.failedConstraint)
        
        XCTAssertEqual(cs.simplify(type: t1), ts)
    }
    
    func testApplicableFunction2() throws {
        let cts = ConstraintSystem()
        
        let t1 = cts.createTypeVariable()
        let ti = PrimitiveType.int
        let ts = PrimitiveType.string
        
        let t2 = cts.createTypeVariable()
        
        // (Int) -> T1 <<app>> T2
        cts.addConstraint(kind: .applicableFunction,
            left: FunctionType(parameter: ti, result: t1),
            right: t2)
        
        let c1 = try XCTUnwrap(cts.constraints.first)
        XCTAssertEqual(c1.constraint.kind, .applicableFunction)
        XCTAssertFalse(c1.isActive)
        
        // T2 <bind> (Int) -> (String)
        cts.addConstraint(kind: .bind,
                          left: t2,
                          right: FunctionType(parameter: ti, result: ts))
        XCTAssertTrue(c1.isActive)
        
        XCTAssertTrue(cts.simplify())
        XCTAssertFalse(cts.constraints.contains(c1))
        
        XCTAssertEqual(cts.simplify(type: t1), ts)
        XCTAssertEqual(cts.simplify(type: t2), FunctionType(parameter: ti, result: ts))
    }
    
    func testApplicableFunctionFail() {
        let cts = ConstraintSystem()
        
        let ti = PrimitiveType.int
        let ts = PrimitiveType.string
        
        cts.addConstraint(kind: .applicableFunction,
                          left: FunctionType(parameter: ti, result: ts),
                          right: FunctionType(parameter: ts, result: ts))
        XCTAssertFalse(cts.simplify())
        XCTAssertNotNil(cts.failedConstraint)
    }
    
    func testApplicableFunction4() {
        let cts = ConstraintSystem()
        
        let t1 = cts.createTypeVariable()
        let ti = PrimitiveType.int
        let toi = OptionalType(PrimitiveType.int)
        let ts = PrimitiveType.string
        
        cts.addConstraint(kind: .applicableFunction,
                          left: FunctionType(parameter: ti, result: t1),
                          right: FunctionType(parameter: toi, result: ts))
        XCTAssertTrue(cts.simplify())
        XCTAssertEqual(cts.simplify(type: t1), ts)
    }
    
    func testConvFunctionEqual() {
        let cts = ConstraintSystem()
        
        let int = PrimitiveType.int
        let str = PrimitiveType.string
        
        cts.addConstraint(kind: .conversion,
                          left: FunctionType(parameter: int,
                                             result: str),
                          right: FunctionType(parameter: int,
                                              result: str))
        XCTAssertTrue(cts.simplify())
    }
    
    func testConvFunctionParamNotEqual() {
        let cts = ConstraintSystem()
        
        let int = PrimitiveType.int
        let str = PrimitiveType.string
        let void = PrimitiveType.void
        
        cts.addConstraint(kind: .conversion,
                          left: FunctionType(parameter: int,
                                             result: void),
                          right: FunctionType(parameter: str,
                                              result: void))
        XCTAssertFalse(cts.simplify())
    }
    
    func testConvFunctionParamCotravarianceInvert() {
        let cts = ConstraintSystem()
        
        let int = PrimitiveType.int
        let oint = OptionalType(int)
        let void = PrimitiveType.void
        
        cts.addConstraint(kind: .conversion,
                          left: FunctionType(parameter: int,
                                             result: void),
                          right: FunctionType(parameter: oint,
                                              result: void))
        XCTAssertFalse(cts.simplify())
    }
    
    func testConvFunctionResultNotEqual() {
        let cts = ConstraintSystem()
        
        let int = PrimitiveType.int
        let str = PrimitiveType.string
        let void = PrimitiveType.void
        
        cts.addConstraint(kind: .conversion,
                          left: FunctionType(parameter: int,
                                             result: void),
                          right: FunctionType(parameter: int,
                                              result: str))
        XCTAssertFalse(cts.simplify())
    }
    
    func testConvFunctionResultCovarianceInvert() {
        let cts = ConstraintSystem()
        
        let int = PrimitiveType.int
        let str = PrimitiveType.string
        let ostr = OptionalType(str)
        
        cts.addConstraint(kind: .conversion,
                          left: FunctionType(parameter: int,
                                             result: ostr),
                          right: FunctionType(parameter: int,
                                              result: str))
        XCTAssertFalse(cts.simplify())
    }
    
    func testConvFunctionResultCovariance() {
        let cts = ConstraintSystem()
        
        let int = PrimitiveType.int
        let str = PrimitiveType.string
        let ostr = OptionalType(str)
        
        cts.addConstraint(kind: .conversion,
                          left: FunctionType(parameter: int,
                                             result: str),
                          right: FunctionType(parameter: int,
                                              result: ostr))
        XCTAssertTrue(cts.simplify())
    }
    
    func testConvFunctionParamContravariance() {
        let cts = ConstraintSystem()
        
        let int = PrimitiveType.int
        let oint = OptionalType(int)
        let str = PrimitiveType.string
        
        cts.addConstraint(kind: .conversion,
                          left: FunctionType(parameter: oint,
                                             result: str),
                          right: FunctionType(parameter: int,
                                              result: str))
        XCTAssertTrue(cts.simplify())
    }
    
    func testConvFunctionParamContravarianceResultCovariance() {
        let cts = ConstraintSystem()
        
        let int = PrimitiveType.int
        let oint = OptionalType(int)
        let str = PrimitiveType.string
        let ostr = OptionalType(str)
        
        cts.addConstraint(kind: .conversion,
                          left: FunctionType(parameter: oint,
                                             result: str),
                          right: FunctionType(parameter: int,
                                              result: ostr))
        XCTAssertTrue(cts.simplify())
    }
    
    func testGatherConstraints1() {
        let cts = ConstraintSystem()
        
        var bindings = TypeVariableBindings()
        
        var t: [TypeVariable] = []
        t.append(TypeVariable(id: 99999))
        for _ in 0..<40 {
            t.append(cts.createTypeVariable())
        }
        for ti in t {
            bindings.setBinding(for: ti, .free)
        }
        
        var cs: [ConstraintEntry] = []
        func add(_ c: Constraint) -> ConstraintEntry {
            let e = ConstraintEntry(c)
            cs.append(e)
            return e
        }
        
        // t1 left
        let c0 = add(.bind(left: t[1], right: t[2]))
        
        // unrelates
        _ = add(.bind(left: t[2], right: t[17]))
        
        // t1 right
        let c1 = add(.bind(left: t[3], right: t[1]))
        
        // unrelates
        _ = add(.bind(left: t[18], right: t[3]))
        
        // t1 nested left
        let c2 = add(.bind(left: FunctionType(parameter: t[1], result: t[4]), right: t[5]))
        
        // t1 nested right
        let c3 = add(.bind(left: t[6], right: FunctionType(parameter: t[1], result: t[7])))
        
        // t8 equiv t1
        bindings.setBinding(for: t[8], .transfer(t[1]))
        
        // t8 nested left
        let c4 = add(.bind(left: FunctionType(parameter: t[8], result: t[9]), right: t[10]))
        
        // t1 assign fix, adj t11, t12
        bindings.setBinding(for: t[1], .fixed(FunctionType(parameter: t[11], result: t[12])))

        // t11 nested left
        let c5 = add(.bind(left: FunctionType(parameter: t[11], result: t[13]), right: t[14]))
        
        // unrelates
        _ = add(.bind(left: t[15], right: t[16]))
        
        // t3 quiv t19
        bindings.setBinding(for: t[19], .transfer(t[3]))
        
        // unrelates
        _ = add(.bind(left: t[19], right: t[20]))
        
        let actual = ConstraintSystem.getherConstraints(involving: t[1],
                                                        constraints: cs,
                                                        bindings: bindings)
        let expected = [c0, c1, c2, c3, c4, c5]
        
        XCTAssertEqual(Set(actual),
                       Set(expected))
    }
    
    func testOptionalEqual() throws {
        let cts = ConstraintSystem()
        let sr = cts.matchTypes(kind: .bind,
                                left: OptionalType(PrimitiveType.int),
                                right: OptionalType(PrimitiveType.int),
                                options: ConstraintSystem.MatchOptions())
        XCTAssertEqual(sr, .solved)
    }
    
    func testConvIntToOptInt() throws {
        
        let cts = ConstraintSystem()
        
        _ = cts.matchTypes(kind: .conversion,
                           left: PrimitiveType.int,
                           right: OptionalType(PrimitiveType.int),
                           options: ConstraintSystem.MatchOptions())
        let sols = cts.solve()
        XCTAssertEqual(sols.count, 1)
    }
        
    func testConvOptIntToOptInt() throws {
        let cts = ConstraintSystem()
        
        _ = cts.matchTypes(kind: .conversion,
                           left: OptionalType(PrimitiveType.int),
                           right: OptionalType(PrimitiveType.int),
                           options: ConstraintSystem.MatchOptions())
        let sols = cts.solve()
        XCTAssertEqual(sols.count, 2)
    }
    
    func testConvOptIntToOptOptInt() throws {
        let cts = ConstraintSystem()
        
        _ = cts.matchTypes(kind: .conversion,
                           left: OptionalType(PrimitiveType.int),
                           right: OptionalType(OptionalType(PrimitiveType.int)),
                           options: ConstraintSystem.MatchOptions())
        let sols = cts.solve()
        XCTAssertEqual(sols.count, 3)
    }
}
