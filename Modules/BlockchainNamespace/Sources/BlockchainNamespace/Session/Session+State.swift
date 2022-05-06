// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation

extension Session {

    public final class State {

        unowned var app: AppProtocol!
        var data: Data

        public init(
            _ data: Tag.Context = [:],
            preferences: Preferences = UserDefaults.standard
        ) {
            self.data = Data(preferences: preferences)
            self.data.store = data.dictionary
        }
    }
}

extension Session.State {

    public class Data {

        public internal(set) var store: [Tag.Reference: Any] = [:]
        internal var subjects: [Tag.Reference: Subject] = [:]
        private var dirty: (data: [Tag.Reference: Any], level: UInt) = ([:], 0)

        private var queue = DispatchQueue(label: "com.blockchain.session.state.queue")
        private var key: DispatchSpecificKey<Data.Type>

        var preferences: Preferences

        private var scope: String {
            store[blockchain.user.id.key] as? String ?? "ø"
        }

        init(preferences: Preferences) {
            key = .init(on: queue)
            self.preferences = preferences
        }
    }
}

extension Session.State.Data {

    private struct Tombstone: Hashable {}

    public struct Computed {
        public let key: Tag.Reference
        public let yield: () throws -> Any
    }
}

extension Session.State {

    public func transaction<Ignored>(_ yield: (Session.State) throws -> Ignored) {
        data.beginTransaction()
        do {
            _ = try yield(self)
            data.endTransaction()
        } catch {
            data.rollbackTransaction()
        }
    }

    public func contains(_ event: Tag.Event) -> Bool {
        data.store.keys.contains(event.key)
    }

    public func clear(_ event: Tag.Event) {
        let key = event.key
        if key.tag.is(blockchain.user.id) {
            transaction { state in
                let user = key
                for key in data.store.keys where key.tag.isNot(blockchain.session.state.shared.value) {
                    guard key != user else { continue }
                    state.clear(key)
                }
            }
        }
        data.clear(key)
    }

    public func set(_ event: Tag.Event, to value: Any) {
        data.set(event.key, to: value)
    }

    public func set(_ event: Tag.Event, to value: @escaping () throws -> Any) {
        let key = event.key
        data.set(key, to: Data.Computed(key: key, yield: value))
    }

    public func get(_ event: Tag.Event) throws -> Any {
        try data.get(event.key)
    }

    public func result(for event: Tag.Event) -> FetchResult {
        let key = event.key
        do {
            return try .value(get(key), key.metadata(.state))
        } catch let error as FetchResult.Error {
            return .error(error, key.metadata(.state))
        } catch {
            return .error(.other(error), key.metadata(.state))
        }
    }

    public func publisher(for event: Tag.Event) -> AnyPublisher<FetchResult, Never> {
        let key = event.key
        return Just(result(for: key))
            .merge(with: data.subject(for: key))
            .eraseToAnyPublisher()
    }
}

extension Session.State.Data {

    public var isInTransaction: Bool { sync { dirty.level > 0 } }
    public var isNotInTransaction: Bool { !isInTransaction }

    public func contains(_ key: Tag.Reference) -> Bool {
        sync { store.keys.contains(key) }
    }

    func get(_ key: Tag.Reference) throws -> Any {
        if let value = sync(execute: { store[key] }) {
            return try (value as? Computed)?.yield() ?? value
        }

        switch key.tag {
        case blockchain.session.state.preference.value:
            guard let value = preferences.object(forKey: blockchain.session.state(\.id))[scope, key.string] else {
                throw FetchResult.Error.keyDoesNotExist(key)
            }
            set(key, to: value)
            return value
        default:
            throw FetchResult.Error.keyDoesNotExist(key)
        }
    }

    func set(_ key: Tag.Reference, to value: Any) {
        sync {
            dirty.data[key] = value
            if isNotInTransaction {
                update([key: value])
            }
        }
    }

    func clear(_ key: Tag.Reference) {
        sync {
            if isInTransaction {
                dirty.data[key] = Tombstone.self
            } else {
                update([key: Tombstone.self])
            }
        }
    }

    func beginTransaction() {
        sync {
            dirty.level += 1
        }
    }

    func endTransaction() {
        sync {
            let data = dirty.data
            switch dirty.level {
            case 1:
                dirty.data.removeAll(keepingCapacity: true)
                dirty.level = 0
                update(data)
            case 1...UInt.max:
                dirty.level -= 1
            default:
                assertionFailure(
                    "Misaligned begin -> end transaction calls. You must be in a transaction to end a transaction."
                )
            }
        }
    }

    func rollbackTransaction() {
        sync {
            precondition(isInTransaction)
            dirty.level = 0
            dirty.data.removeAll(keepingCapacity: true)
        }
    }

    func subject(for key: Tag.Reference) -> Session.State.Subject {
        sync {
            let subject = subjects[key, default: .init()]
            subjects[key] = subject
            return subject
        }
    }

    private func update(_ data: [Tag.Reference: Any]) {
        sync {
            for (key, value) in data {
                switch value {
                case is Tombstone.Type:
                    store.removeValue(forKey: key)
                default:
                    store[key] = value
                }
            }
            preferences.transaction(blockchain.session.state(\.id)) { object in
                var dictionary = object[scope] as? [String: Any] ?? [:]
                for (key, value) in data.filter({ key, _ in key.tag.is(blockchain.session.state.preference.value) }) {
                    if value is Tombstone.Type {
                        dictionary.removeValue(forKey: key.id())
                    } else {
                        dictionary[key.id()] = value
                    }
                }
                object[scope] = dictionary
            }
            for (key, value) in data {
                switch value {
                case is Tombstone.Type:
                    subjects[key]?.send(.error(.keyDoesNotExist(key), key.metadata(.state)))
                default:
                    subjects[key]?.send(.value(value, key.metadata(.state)))
                }
            }
        }
    }

    @discardableResult
    func sync<T>(execute work: () throws -> T) rethrows -> T {
        DispatchQueue.getSpecific(key: key) == nil
            ? try queue.sync(execute: work)
            : try work()
    }
}

extension Session.State {
    public typealias Subject = PassthroughSubject<FetchResult, Never>
}

extension DispatchSpecificKey {
    convenience init<K>(_: K.Type = K.self, on queue: DispatchQueue) where T == K.Type {
        self.init()
        queue.setSpecific(key: self, value: K.self)
    }
}
