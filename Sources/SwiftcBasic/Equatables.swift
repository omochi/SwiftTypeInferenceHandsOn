import Foundation

public enum Equatables {
    // strict dispatch helper
    public static func isEqual<T: Equatable>(_ a: T, _ b: T) -> Bool {
        return a == b
    }
}
