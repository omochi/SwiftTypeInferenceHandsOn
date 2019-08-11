import SwiftcAST

func main() throws {
    let file = Resources.file("a.swift")
    let parser = try Parser(file: file)
    let sf = try parser.parse()
    dump(sf)
}

try! main()
