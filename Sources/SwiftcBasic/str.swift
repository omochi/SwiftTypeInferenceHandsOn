public func str<T: CustomStringConvertible>(_ x: T?) -> String {
    return x?.description ?? "(nil)"
}
