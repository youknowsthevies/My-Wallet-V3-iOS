// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation

extension Session {

    public typealias Events = PassthroughSubject<Session.Event, Never>

    public struct Event: Identifiable {

        public let id: UInt
        public let date: Date
        public let tag: Tag
        public let context: Tag.Context

        init(date: Date = Date(), tag: Tag, context: Tag.Context = [:]) {
            id = Self.id
            self.date = date
            self.tag = tag
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

    public func `is`(_ type: L) -> Publishers.Filter<Self> {
        filter { $0.tag.is(type) }
    }

    public func `is`(_ type: Tag) -> Publishers.Filter<Self> {
        filter { $0.tag.is(type) }
    }

    public func `is`<S: Sequence>(_ types: S) -> Publishers.Filter<Self> where S.Element == Tag {
        filter { $0.tag.is(types) }
    }
}
