import SwiftSyntax

extension TypeInferer {
    // MARK:- dump
    internal func dump(syntax: Syntax) {
        let printer = Dumper(owner: self)
        printer.print(syntax)
        
        Swift.print("Substitutions:")
        Swift.print(unificator.description)
    }
    
    private final class Dumper {
        private let owner: TypeInferer
        
        private var depth: Int = 0
        private var needsIndent: Bool = true
        
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
            case let syntax as FunctionCallExprSyntax:
                print("FunctionCall")
                if let name = syntax.calledExpression as? IdentifierExprSyntax {
                    nest {
                        print("callee: \(name.identifier.text)")
                    }
                }
                for (index, argument) in syntax.argumentList.enumerated() {
                    nest {
                        print("arg[\(index)]=", newLine: false)
                        print(argument.expression)
                    }
                }
            case let syntax as InitializerClauseSyntax:
                print(syntax.value)
            case let syntax as IntegerLiteralExprSyntax:
                print("\(syntax.digits.text) : \(typeString(for: syntax))")
            case let syntax as ClosureExprSyntax:
                print("Closure: \(typeString(for: syntax))")
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
            return owner.mappedType(for: syntax)?.description ?? "??"
        }
        
        private func print(_ string: String, newLine: Bool = true) {
            if needsIndent {
                let indent = String(repeating: "  ", count: depth)
                Swift.print(indent, terminator: "")
                needsIndent = false
            }
            
            if newLine {
                Swift.print(string)
                needsIndent = true
            } else {
                Swift.print(string, terminator: "")
            }
        }
        
        private func nest(_ f: () -> Void) {
            depth += 1
            f()
            depth -= 1
        }
    }
}
