// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation

extension Session {

    public typealias Events = PassthroughSubject<Session.Event, Never>

    public struct Event: Identifiable {

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
        filter { $0.tag.is(type) }
    }

    public func filter(_ type: Tag) -> Publishers.Filter<Self> {
        filter { $0.tag.is(type) }
    }

    public func filter(_ type: Tag.Reference) -> Publishers.Filter<Self> {
        filter { $0.ref == type }
    }

    public func filter<S: Sequence>(_ types: S) -> Publishers.Filter<Self> where S.Element == Tag {
        filter { $0.tag.is(types) }
    }

    public func filter<S: Sequence>(_ types: S) -> Publishers.Filter<Self> where S.Element == Tag.Reference {
        filter { types.contains($0.ref) }
    }
}
