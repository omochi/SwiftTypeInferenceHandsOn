import SwiftcType

public protocol DeclContext : AnyObject {
    var parentContext: DeclContext? { get }
    
    var interfaceType: Type? { get }
    
    func resolveInSelf(name: String) -> [ValueDecl]

    func resolve(name: String) -> [ValueDecl]
}

extension DeclContext {
    public func resolve(name: String) -> [ValueDecl] {
        var contextOr: DeclContext? = self
        while let context = contextOr {
            let decls = context.resolveInSelf(name: name)
            if !decls.isEmpty {
                return decls
            }
            contextOr = context.parentContext
        }
        return []
    }
}
