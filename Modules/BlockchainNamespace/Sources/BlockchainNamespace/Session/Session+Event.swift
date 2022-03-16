// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation

extension Session {

    public typealias Events = PassthroughSubject<Session.Event, Never>

    public struct Event: Identifiable, Hashable {

        public let id: UInt
        public let date: Date
        public let ref: Tag.Reference
        public let context: Tag.Context

        public var tag: Tag { ref.tag }

        init(date: Date = Date(), ref: Tag.Reference, context: Tag.Context = [:]) {
            id = Self.id
            self.date = date
            self.ref = ref
            self.context = context
        }

        public func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }

        public static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.id == rhs.id
        }
    }
}

extension Session.Event {
    private static var count: UInt = 0
    private static let lock = NSLock()
    private static var id: UInt {
        lock.lock()
        defer { lock.unlock() }
        count += 1
        return count
    }
}

extension Publisher where Output == Session.Event {

    public func filter(_ type: L) -> Publishers.Filter<Self> {
        filter(type[])
    }

    public func filter(_ type: Tag) -> Publishers.Filter<Self> {
        filter(type.ref())
    }

    public func filter(_ type: Tag.Reference) -> Publishers.Filter<Self> {
        filter { event in event.ref.matches(type) }
    }

    public func filter<S: Sequence>(_ types: S) -> Publishers.Filter<Self> where S.Element == Tag {
        filter { $0.tag.is(types) }
    }

    public func filter<S: Sequence>(_ types: S) -> Publishers.Filter<Self> where S.Element == Tag.Reference {
        filter { event in types.contains(where: { type in event.ref.matches(type) }) }
    }
}

extension Tag.Reference {

    func matches(_ other: Tag.Reference) -> Bool {
        if self == other { return true }
        guard tag.is(other.tag) else { return false }
        return indices.pairs().isSuperset(of: other.context.filterValues(String.self).pairs())
    }
}

extension Dictionary {

    func filterValues<T>(_ type: T.Type) -> [Key: T] {
        compactMapValues { $0 as? T }
    }
}

extension Dictionary where Value: Hashable {

    struct Pair: Hashable {
        let key: Key
        let value: Value
    }

    func pairs() -> Set<Pair> {
        map(Pair.init).set
    }
}
