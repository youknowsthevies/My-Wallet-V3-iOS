// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

extension Dictionary {

    func mapKeys<A>(_ transform: (Key) throws -> A) rethrows -> [A: Value] {
        try reduce(into: [:]) { a, e in try a[transform(e.key)] = e.value }
    }

    func mapKeysAndValues<A, B>(key: (Key) throws -> A, value: (Value) throws -> B) rethrows -> [A: B] {
        try reduce(into: [:]) { a, e in try a[key(e.key)] = value(e.value) }
    }
}

extension Dictionary {

    static func + (lhs: Dictionary, rhs: Dictionary) -> Dictionary {
        lhs.merging(rhs, uniquingKeysWith: { $1 })
    }

    static func += (lhs: inout Dictionary, rhs: Dictionary) {
        lhs.merge(rhs, uniquingKeysWith: { $1 })
    }
}

extension Dictionary where Key == L, Value == String {
    public func toTagString() -> [Tag: Value] { mapKeys(\.[]) }
}

extension Dictionary where Key == L, Value == Any {
    public func toTagAny() -> [Tag: Value] { mapKeys(\.[]) }
}

extension Dictionary where Key == Tag {
    public subscript(id: L) -> Value? { self[id[]] }
}
