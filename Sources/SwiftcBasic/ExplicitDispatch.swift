import Foundation

public enum ExplicitDispatch {
    public static func isEqual<T: Equatable>(_ a: T, _ b: T) -> Bool {
        return a == b
    }
}
