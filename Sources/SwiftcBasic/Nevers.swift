import Foundation

public func unimplemented(file: StaticString = #file,
                          line: UInt = #line) -> Never {
    fatalError("unimplemented", file: file, line: line)
}

public func abstract(file: StaticString = #file,
                     line: UInt = #line) -> Never {
    fatalError("abstract", file: file, line: line)
}
