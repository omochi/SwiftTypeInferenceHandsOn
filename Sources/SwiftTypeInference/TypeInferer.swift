import SwiftSyntax

public final class TypeInferer {
    public init() {
    }
    
    private var lastTypeVariableID: Int = 0
    private var syntaxTypeMap: [SyntaxIdentifier: (syntax: Syntax, type: AnyType)] = [:]
    private var constraints: [Constraint] = []
    
    public func infer(statement: Syntax) -> Syntax {
        var visitor = CollectVisitor(owner: self)
        statement.walk(&visitor)
        
        print(syntax: statement)
        
        let writer = AnnotateRewriter(owner: self)
        return writer.visit(statement)
    }
    
    private func collectConstraints(expression: Syntax) {
        var visitor = CollectVisitor(owner: self)
        expression.walk(&visitor)
    }
    
    private func createTypeVariable() -> TypeVariable {
        let id = lastTypeVariableID + 1

        let tv = TypeVariable(id: id)
        lastTypeVariableID = tv.id
        return tv
    }
    
    private func bindType<T: Type>(for syntax: Syntax, type: T) {
        syntaxTypeMap[syntax.uniqueIdentifier] = (syntax, type.asAnyType())
    }
    
    private func type(for syntax: Syntax) -> AnyType? {
        return syntaxTypeMap[syntax.uniqueIdentifier]?.type
    }
    
    private func constrain<L: Type, R: Type>(_ left: L, _ right: R) {
        constraints.append(Constraint(left: left, right: right))
    }
    
    private func collect(binding: PatternBindingSyntax) {
        func collectPattern() -> AnyType? {
            switch binding.pattern {
            case let pattern as IdentifierPatternSyntax:
                let tv = createTypeVariable()
                                
                bindType(for: pattern, type: tv)
                return tv.asAnyType()
            default:
                return nil
            }
        }
        
        let t1 = collectPattern()
        
        if let initializer = binding.initializer {
            if let t2 = collect(expr: initializer.value) {
                if let t1 = t1 {
                    constrain(t1, t2)
                }
            }
        }
    }
    
    private func collect(expr: ExprSyntax) -> AnyType? {
        switch expr {
        case let expr as IntegerLiteralExprSyntax:
            let tv = createTypeVariable()
            bindType(for: expr, type: tv)
            constrain(tv, IntType())
            return tv.asAnyType()
        default:
            return nil
        }
    }
    
    private func annotate(binding: PatternBindingSyntax) -> PatternBindingSyntax {
        var binding = binding
        
        func proc() {
            guard var pattern = binding.pattern as? IdentifierPatternSyntax else { return }
            
            guard let tv = type(for: pattern) else { return }

            let trivia = pattern.identifier.trailingTrivia
                .appending(.blockComment("/* : \(tv) */"))
            let identifier = pattern.identifier
                .withTrailingTrivia(trivia)
            
            pattern = pattern.withIdentifier(identifier)
        
            binding = binding
                .withPattern(pattern)
        }
        
        proc()
        
        return binding
    }
    
    private func print(syntax: Syntax) {
        let printer = Printer(owner: self)
        printer.print(syntax)
        
        Swift.print("Constraints:")
        
        for c in constraints {
            Swift.print("  \(c.left) = \(c.right)")
        }
    }
    
    private final class Printer {
        private let owner: TypeInferer
        
        private var depth: Int = 0
        
        public init(owner: TypeInferer) {
            self.owner = owner
        }
        
        public func print(_ syntax: Syntax) {
            switch syntax {
            case let syntax as VariableDeclSyntax:
                print("VarDecl")
                for binding in syntax.bindings {
                    nest {
                        print(binding)
                    }
                }
            case let syntax as PatternBindingSyntax:
                print("PatternBinding")
                
                if let pattern = syntax.pattern as? IdentifierPatternSyntax {
                    nest {
                        print("\(pattern.identifier.text) : \(typeString(for: pattern))")
                    }
                }
                if let initializer = syntax.initializer {
                    nest {
                        print(initializer)
                    }
                }
            case let syntax as InitializerClauseSyntax:
                print(syntax.value)
            case let syntax as IntegerLiteralExprSyntax:
                print("\(syntax.digits.text) : \(typeString(for: syntax))")
            case let syntax as SequenceExprSyntax:
                print("SequenceExpr")
                for item in syntax.elements {
                    nest {
                        print(item)
                    }
                }
            case let syntax as BinaryOperatorExprSyntax:
                print(syntax.operatorToken.text)
            case let syntax as ExprSyntax:
                print("Expr")
                for item in syntax.children {
                    nest {
                        print(item)
                    }
                }
            case let syntax as TokenSyntax:
                print("Token: \(syntax.text)")
            default:
                print("??")
            }
        }
        
        private func typeString(for syntax: Syntax) -> String {
            return owner.type(for: syntax)?.description ?? "??"
        }
        
        private func print(_ string: String) {
            let indent = String(repeating: "  ", count: depth)
            Swift.print(indent + string)
        }
        
        private func nest(_ f: () -> Void) {
            depth += 1
            f()
            depth -= 1
        }
    }
    
    private final class CollectVisitor : SyntaxVisitorBase {
        private let owner : TypeInferer
        
        public init(owner: TypeInferer) {
            self.owner = owner
        }
        
        public override func visit(_ node: VariableDeclSyntax) -> SyntaxVisitorContinueKind {
            for binding in node.bindings {
                owner.collect(binding: binding)
            }
            
            return .skipChildren
        }
    }
    
    private final class AnnotateRewriter : SyntaxRewriter {
        private let owner: TypeInferer
        
        public init(owner: TypeInferer) {
            self.owner = owner
        }
        
        public override func visit(_ node: PatternBindingSyntax) -> Syntax {
            return owner.annotate(binding: node)
        }
    }
}
