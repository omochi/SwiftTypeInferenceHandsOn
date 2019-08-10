import XCTest
import SwiftcTest
import SwiftcType
import SwiftcSema

final class ConstraintSystemTests: XCTestCase {
    func testMergeVars() {
        let cs = ConstraintSystem()
        let t1 = cs.createTypeVariable()
        XCTAssertEqual(cs.fixedOrRepresentative(for: t1), t1)
        
        let t2 = cs.createTypeVariable()
        XCTAssertEqual(cs.fixedOrRepresentative(for: t2), t2)
        
        cs.addConstraint(.bind(left: t1, right: t2))
        XCTAssertEqual(t2.equivalentTypeVariables, [])
        
        XCTAssertEqual(cs.fixedOrRepresentative(for: t1), t1)
        XCTAssertEqual(cs.fixedOrRepresentative(for: t2), t1)
        XCTAssertEqual(t1.equivalentTypeVariables, [t2])
        
        let t3 = cs.createTypeVariable()
        cs.addConstraint(.bind(left: t1, right: t3))
        XCTAssertEqual(cs.fixedOrRepresentative(for: t3), t1)
        
        let t4 = cs.createTypeVariable()
        cs.addConstraint(.bind(left: t2, right: t4))
        XCTAssertEqual(cs.fixedOrRepresentative(for: t4), t1)
        
        let t5 = cs.createTypeVariable()
        let t6 = cs.createTypeVariable()
        cs.addConstraint(.bind(left: t6, right: t5))
        XCTAssertEqual(cs.fixedOrRepresentative(for: t5), t5)
        XCTAssertEqual(cs.fixedOrRepresentative(for: t6), t5)
        
        cs.addConstraint(.bind(left: t6, right: t2))
        XCTAssertEqual(cs.fixedOrRepresentative(for: t5), t1)
        XCTAssertEqual(cs.fixedOrRepresentative(for: t6), t1)
        XCTAssertEqual(t1.equivalentTypeVariables, [t2, t3, t4, t5, t6])
    }
    
    func testMergeVarFix() {
        let cs = ConstraintSystem()
        let t1 = cs.createTypeVariable()
        let ti = PrimitiveType.int
        
        cs.addConstraint(.bind(left: t1, right: ti))
    }
    
    func testTypeTypeVariables() {
        let cs = ConstraintSystem()
        let t1 = cs.createTypeVariable()
        let t2 = cs.createTypeVariable()
        let t3 = cs.createTypeVariable()
        
        // (T1) -> (T2) -> (T3)
        let tf = FunctionType(argument: t1,
                              result: FunctionType(argument: t2,
                                                   result: t3))
        
        XCTAssertEqual(tf.typeVariables, [t1, t2, t3])        
    }
}
