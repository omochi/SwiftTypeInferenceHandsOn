import SwiftcType
import SwiftcAST

public struct OverloadChoice : CustomStringConvertible, Hashable {
    public struct Eq : Hashable {
        public var decl: AnyASTNode
        public init(_ x: OverloadChoice) {
            self.decl = x.decl.eraseToAnyASTNode()
        }
    }
    
    public var decl: ValueDecl
    
    public init(decl: ValueDecl) {
        self.decl = decl
    }
    
    public var description: String {
        return "(decl=\(decl))"
    }
    
    public static func == (lhs: OverloadChoice, rhs: OverloadChoice) -> Bool {
        Eq(lhs) == Eq(rhs)
    }
    
    public func hash(into hasher: inout Hasher) {
        Eq(self).hash(into: &hasher)
    }
    
    public var containingTypes: [Type] {
        // basetype
        return []
    }
}
