extension Dictionary {

    func compactMapKeys<T>(_ keyPath: KeyPath<Key, T?>) -> [T: Value] {
        reduce(into: [T: Value]()) { result, x in
            if let key = x.key[keyPath: keyPath] {
                result[key] = x.value
            }
        }
    }
}
