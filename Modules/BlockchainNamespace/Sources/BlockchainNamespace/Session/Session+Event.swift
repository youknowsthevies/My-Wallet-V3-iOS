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

        public let source: (file: String, line: Int)

        public var tag: Tag { ref.tag }

        init(
            date: Date = Date(),
            ref: Tag.Reference,
            context: Tag.Context = [:],
            file: String = #fileID,
            line: Int = #line
        ) {
            id = Self.id
            self.date = date
            self.ref = ref
            self.context = context
            source = (file, line)
        }

        public func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }

        public static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.id == rhs.id
        }
    }
}

extension Session.Event: CustomStringConvertible {
    public var description: String { ref.string }
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

extension AppProtocol {

    @inlinable public func on(
        _ first: L,
        _ rest: L...,
        file: String = #fileID,
        line: Int = #line,
        action: @escaping (Session.Event) async throws -> Void
    ) -> BlockchainEventSubscription {
        BlockchainEventSubscription(
            app: self,
            events: ([first] + rest).map { language[$0].ref(in: self) },
            file: file,
            line: line,
            action: action
        )
    }

    @inlinable public func on(
        _ first: Tag,
        _ rest: Tag...,
        file: String = #fileID,
        line: Int = #line,
        action: @escaping (Session.Event) async throws -> Void
    ) -> BlockchainEventSubscription {
        BlockchainEventSubscription(
            app: self,
            events: ([first] + rest).map { $0.ref(in: self) },
            file: file,
            line: line,
            action: action
        )
    }

    @inlinable public func on(
        _ first: Tag.Reference,
        _ rest: Tag.Reference...,
        file: String = #fileID,
        line: Int = #line,
        action: @escaping (Session.Event) async throws -> Void
    ) -> BlockchainEventSubscription {
        BlockchainEventSubscription(
            app: self,
            events: [first] + rest,
            file: file,
            line: line,
            action: action
        )
    }
}

public final class BlockchainEventSubscription {

    let app: AppProtocol
    let events: [Tag.Reference]
    let action: (Session.Event) async throws -> Void

    let file: String, line: Int

    @usableFromInline init(
        app: AppProtocol,
        events: [Tag.Reference],
        file: String,
        line: Int,
        action: @escaping (Session.Event) async throws -> Void
    ) {
        self.app = app
        self.events = events
        self.file = file
        self.line = line
        self.action = action
    }

    private var subscription: AnyCancellable?

    public func start() {
        guard subscription == nil else { return }
        subscription = app.on(events).sink(
            receiveValue: { [weak self] event in
                Task { [weak self] in
                    guard let self = self else { return }
                    do {
                        try await self.action(event)
                    } catch {
                        self.app.post(error: error, file: self.file, line: self.line)
                    }
                }
            }
        )
    }

    public func stop() {
        subscription?.cancel()
    }
}
