//import SwiftSyntax
//
//extension TypeSyntax {
//    public func toType() throws -> Type {
//        switch self {
//        case let syntax as SimpleTypeIdentifierSyntax:
//            let name = syntax.name.description
//            switch name {
//            case "Void": return VoidType()
//            case "Int": return IntType()
//            case "String": return StringType()
//            default: break
//            }
//        case let syntax as FunctionTypeSyntax:
//            let arguments = try syntax.arguments.map { (arg) in
//                try arg.type.toType()
//            }
//            let result = try syntax.returnType.toType()
//            return FunctionType(arguments: arguments,
//                                result: result)
//        default:
//            break
//        }
//        throw MessageError("unsupported type: \(self)")
//    }
//}
