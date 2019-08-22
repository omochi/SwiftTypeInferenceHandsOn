import XCTest
import SwiftcTest

final class ConstraintSystemTests: XCTestCase {
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
        
        cs.addConstraint(.bind(left: t1, right: t2))
        XCTAssertEqual(t2.equivalentTypeVariables(bindings: cs.bindings), [])
        
        XCTAssertEqual(cs.simplify(type: t1), t1)
        XCTAssertEqual(cs.simplify(type: t2), t1)
        XCTAssertEqual(t1.equivalentTypeVariables(bindings: cs.bindings), [t1, t2])
        
        let t3 = cs.createTypeVariable()
        cs.addConstraint(.bind(left: t1, right: t3))
        XCTAssertEqual(cs.simplify(type: t3), t1)
        
        let t4 = cs.createTypeVariable()
        cs.addConstraint(.bind(left: t2, right: t4))
        XCTAssertEqual(cs.simplify(type: t4), t1)
        
        let t5 = cs.createTypeVariable()
        let t6 = cs.createTypeVariable()
        cs.addConstraint(.bind(left: t6, right: t5))
        XCTAssertEqual(cs.simplify(type: t5), t5)
        XCTAssertEqual(cs.simplify(type: t6), t5)
        
        cs.addConstraint(.bind(left: t6, right: t2))
        XCTAssertEqual(cs.simplify(type: t5), t1)
        XCTAssertEqual(cs.simplify(type: t6), t1)
        XCTAssertEqual(t1.equivalentTypeVariables(bindings: cs.bindings), [t1, t2, t3, t4, t5, t6])
    }
    
    func testMatchVarInt() {
        let cs = ConstraintSystem()
        let t1 = cs.createTypeVariable()
        let ti = PrimitiveType.int
        
        cs.addConstraint(.bind(left: t1, right: ti))
        XCTAssertEqual(cs.simplify(type: t1), ti)
    }
    
    func testMatchIntVar() {
        let cs = ConstraintSystem()
        let t1 = cs.createTypeVariable()
        let ti = PrimitiveType.int
        
        cs.addConstraint(.bind(left: ti, right: t1))
        XCTAssertEqual(cs.simplify(type: t1), ti)
    }
    
    func testMatchIntInt() {
        let cs = ConstraintSystem()
        let ti = PrimitiveType.int
        
        cs.addConstraint(.bind(left: ti, right: ti))
        XCTAssertNil(cs.failedConstraint)
    }
    
    func testMatchIntString() {
        let cs = ConstraintSystem()
        let ti = PrimitiveType.int
        let ts = PrimitiveType.string
        
        cs.addConstraint(.bind(left: ti, right: ts))
        XCTAssertNotNil(cs.failedConstraint)
    }
    
    func testMatchIntString2() {
        let cs = ConstraintSystem()
        let t1 = cs.createTypeVariable()
        let t2 = cs.createTypeVariable()
        let ti = PrimitiveType.int
        let ts = PrimitiveType.string
        
        cs.addConstraint(.bind(left: t1, right: ti))
        cs.addConstraint(.bind(left: t2, right: ts))
        XCTAssertNil(cs.failedConstraint)
        
        cs.addConstraint(.bind(left: t1, right: t2))
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
        cs.addConstraint(.bind(left: FunctionType(parameter: t1, result: t2),
                               right: FunctionType(parameter: ti, result: ts)))
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
        cs.addConstraint(.bind(left: t1,
                               right: FunctionType(parameter: ti, result: t3)))
        
        // (T2) -> String  :bind:   T1
        cs.addConstraint(.bind(left: FunctionType(parameter: t2, result: ts),
                               right: t1))
        
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
        cs.addConstraint(.bind(left: t1, right: FunctionType(parameter: t2, result: t3)))
        
        // T4 :bind: (Int) -> Int
        cs.addConstraint(.bind(left: t4, right: FunctionType(parameter: ti, result: ti)))
        
        // T5 :bind: (String) -> String
        cs.addConstraint(.bind(left: t5, right: FunctionType(parameter: ts, result: ts)))
                
        // T2 :bind: T4
        cs.addConstraint(.bind(left: t2, right: t4))
        
        // T3 :bind: T5
        cs.addConstraint(.bind(left: t3, right: t5))

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
        
        cs.addConstraint(.applicableFunction(
            left: FunctionType(parameter: ti, result: t1),
            right: FunctionType(parameter: ti, result: ts)))
        
        XCTAssertNil(cs.failedConstraint)
        
        XCTAssertEqual(cs.simplify(type: t1), ts)
    }
    
    func testApplicableFunction2() {
        let cs = ConstraintSystem()
        
        let t1 = cs.createTypeVariable()
        let ti = PrimitiveType.int
        let ts = PrimitiveType.string
        
        let t2 = cs.createTypeVariable()
        
        cs.addConstraint(.applicableFunction(
            left: FunctionType(parameter: ti, result: t1),
            right: t2))
        
        
        XCTAssertNil(cs.failedConstraint)
        
        cs.dump()
        
        XCTAssertEqual(cs.simplify(type: t1), ts)
    }
    
    func testGatherConstraints1() {
        let cs = ConstraintSystem()
        
        var css: [ConstraintEntry] = []
        
        var bindings = TypeVariableBindings()
        
        var t: [TypeVariable] = []
        t.append(TypeVariable(id: 99999))
        for _ in 0..<20 {
            t.append(cs.createTypeVariable())
        }
        for ti in t {
            bindings.setBinding(for: ti, .fixed(nil))
        }
        
        // [0] t1 left
        css.append(ConstraintEntry(.bind(left: t[1], right: t[2])))
        // [1] t1 right
        css.append(ConstraintEntry(.bind(left: t[3], right: t[1])))
        
        // [2] t1 nested left
        css.append(ConstraintEntry(.bind(left: FunctionType(parameter: t[1], result: t[4]), right: t[5])))
        
        // [3] t1 nested right
        css.append(ConstraintEntry(.bind(left: t[6], right: FunctionType(parameter: t[1], result: t[7]))))
        
        // t8 equiv t1
        bindings.setBinding(for: t[8], .equivalent(t[1]))
        
        // [4] t8 nested left
        css.append(ConstraintEntry(.bind(left: FunctionType(parameter: t[8], result: t[9]), right: t[10])))
        
        // t1 assign fix, adj t11, t12
        bindings.setBinding(for: t[1], .fixed(FunctionType(parameter: t[11], result: t[12])))

        // [5] t11 nested left
        css.append(ConstraintEntry(.bind(left: FunctionType(parameter: t[11], result: t[13]), right: t[14])))
        
        // [6] unrelates
        css.append(ConstraintEntry(.bind(left: t[15], right: t[16])))
        
        let actual = ConstraintSystem.getherConstraints(involving: t[1],
                                                        constraints: css,
                                                        bindings: bindings)
        let expected = [css[0], css[1], css[2], css[3], css[4], css[5]]
        
        XCTAssertEqual(Set(actual),
                       Set(expected))
    }

}
