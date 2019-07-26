import SwiftSyntax

public struct SyntaxTypeCollector {
    public var syntax: Syntax
    public var tvGen: TypeVariableGenerator
    public var syntaxTypeMap: SyntaxTypeMap
    public var constraints: [Constraint]
    
    public init(syntax: Syntax,
                typeVariableGenerator: TypeVariableGenerator)
    {
        self.syntax = syntax
        self.tvGen = typeVariableGenerator
        self.syntaxTypeMap = [:]
        self.constraints = []
    }
    
    public mutating func collect() {
        switch syntax {
        case let decl as VariableDeclSyntax:
            for binding in decl.bindings {
                collect(binding)
            }
        default:
            break
        }
    }
    
    private mutating func collect(_ binding: PatternBindingSyntax) {
        if let t1 = collect(binding.pattern),
            let initializer = binding.initializer,
            let t2 = collect(initializer.value)
        {
            constrain(t1, t2)
        }
    }
    
    private mutating func collect(_ pattern: PatternSyntax) -> Type? {
        switch pattern {
        case let pattern as IdentifierPatternSyntax:
            let tv = tvGen.generate()
            bindType(for: pattern, type: tv)
            return tv
        default:
            return nil
        }
    }
    
    private mutating func collect(_ expr: ExprSyntax) -> Type? {
        switch expr {
        case let expr as IntegerLiteralExprSyntax:
            let tv = tvGen.generate()
            bindType(for: expr, type: tv)
            constrain(tv, IntType())
            return tv
        default:
            return nil
        }
    }
    
    private mutating func bindType(for syntax: Syntax, type: Type) {
        syntaxTypeMap[syntax.uniqueIdentifier] = SyntaxTypePair(syntax: syntax, type: type)
    }
    
    private mutating func constrain(_ t1: Type, _ t2: Type) {
        constraints.append(Constraint(left: t1, right: t2))
    }
}
