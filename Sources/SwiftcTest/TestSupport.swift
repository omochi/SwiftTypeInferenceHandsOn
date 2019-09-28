import XCTest
@_exported import SwiftcBasic
@_exported import SwiftcType
@_exported import SwiftcAST
@_exported import SwiftcSema

public func XCTAssertEqual(_ a: Type, _ b: Type,
                           file: StaticString = #file,
                           line: UInt = #line)
{
    XCTAssertEqual(a.eraseToAnyType(),
                   b.eraseToAnyType(),
                   file: file, line: line)
}

public func XCTAssertEqual(_ a: Type?, _ b: Type?,
                           file: StaticString = #file,
                           line: UInt = #line)
{
    XCTAssertEqual(a.map { $0.eraseToAnyType() },
                   b.map { $0.eraseToAnyType() })
}

public func XCTAssertEqual(_ a: [Type], _ b: [Type],
                           file: StaticString = #file,
                           line: UInt = #line)
{
    XCTAssertEqual(a.map { $0.eraseToAnyType() },
                   b.map { $0.eraseToAnyType() },
                   file: file, line: line)
}

public func XCTArrayGet<T>(_ array: [T], _ index: Int) throws -> T {
    guard index < array.count else {
        throw MessageError("failure: (index: \(index)) <= (count: \(array.count))")
    }
    return array[index]
}

public func XCTCast<T, U>(_ x: U, _ ty: T.Type) throws -> T {
    guard let cx = x as? T else {
        throw MessageError("cast failure: \(type(of: x)) to \(T.self)")
    }
    return cx
}
