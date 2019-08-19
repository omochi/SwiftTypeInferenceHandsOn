import XCTest
@_exported import SwiftcBasic
@_exported import SwiftcType
@_exported import SwiftcAST
@_exported import SwiftcSema

public func XCTAssertEqual(_ a: Type, _ b: Type,
                           file: StaticString = #file,
                           line: UInt = #line)
{
    XCTAssertEqual(a.wrapInEquatable(),
                   b.wrapInEquatable(),
                   file: file, line: line)
}

public func XCTAssertEqual(_ a: [Type], _ b: [Type],
                           file: StaticString = #file,
                           line: UInt = #line)
{
    XCTAssertEqual(a.map { $0.wrapInEquatable() },
                   b.map { $0.wrapInEquatable() },
                   file: file, line: line)
}

public func XCTArrayGet<T>(_ array: [T], _ index: Int) throws -> T {
    guard index < array.count else {
        throw MessageError("failure: (index: \(index)) <= (count: \(array.count))")
    }
    return array[index]
}

public func XCTCast<T>(_ x: Any?, _ ty: T.Type) throws -> T {
    guard let cx = x as? T else {
        throw MessageError("cast failure: \(type(of: x)) to \(T.self)")
    }
    return cx
}
