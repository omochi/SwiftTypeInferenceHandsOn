public protocol ValueDecl : Decl {
    var name: String { get set }
}

public enum ValueDecls {
    public static func descriptionParts(_ decl: ValueDecl) -> [String] {
        var parts: [String] = []
        
        parts.append("name=\(decl.name)")
        
        parts += Decls.descriptionParts(decl)
        
        return parts
    }
}
