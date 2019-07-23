import Foundation

public protocol Type : CustomStringConvertible, Equatable {
    func map(_ f: (AnyType) throws -> AnyType) rethrows -> AnyType
}

