import XCTest
import SwiftcType

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
