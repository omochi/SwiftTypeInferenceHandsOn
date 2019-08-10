import Foundation

public func ==(a: Type?, b: Type?) -> Bool {
    switch (a, b) {
    case (.some(let a), .some(let b)): return a == b
    case (.some, .none): return false
    case (.none, .some): return false
    case (.none, .none): return true
    }
}

public func ==<S: Sequence>(a: S, b: S) -> Bool
    where S.Element == (Type)
{
    a.elementsEqual(b) { (a, b) in a == b }
}
