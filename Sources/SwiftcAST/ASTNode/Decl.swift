public protocol Decl : DeclContext, ASTNode {
    
}

public enum Decls {
    public static func descriptionParts(_ decl: Decl) -> [String] {
        DeclContexts.descriptionParts(decl) +
            ASTNodes.descriptionParts(decl)
    }
}
