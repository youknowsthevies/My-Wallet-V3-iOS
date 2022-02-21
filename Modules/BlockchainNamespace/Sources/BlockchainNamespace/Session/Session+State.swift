// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation

extension Session {

    public final class State {

        unowned var app: AppProtocol!
        var data = Data()

        public init(_ data: [Tag: Any] = [:]) {
            self.data.store = data
        }
    }
}

extension Session.State {

    public class Data {

        public internal(set) var store: [Tag: Any] = [:]
        internal var subjects: [Tag: Subject] = [:]
        private var dirty: (data: [Tag: Any], level: UInt) = ([:], 0)

        private var queue = DispatchQueue(label: "com.blockchain.session.state.queue")
        private var key: DispatchSpecificKey<Data.Type>

        init() { key = .init(on: queue) }
    }

    public enum Error: Swift.Error {
        case keyDoesNotExist(Tag)
        case other(Swift.Error)
    }
}

extension Session.State.Data {

    private struct Tombstone: Hashable {}

    public struct Computed {
        public let key: Tag
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

    public func contains(_ id: L) -> Bool { contains(id[]) }
    public func contains(_ tag: Tag) -> Bool {
        data.store.keys.contains(tag)
    }

    public func clear(_ id: L) { clear(id[]) }
    public func clear(_ tag: Tag) {
        if tag.is(blockchain.user.id) {
            for key in data.store.keys where tag.isNot(blockchain.session.state.shared.value) {
                data.clear(key)
            }
        }
        data.clear(tag)
    }

    public func set(_ id: L, to value: Any) { set(id[], to: value) }
    public func set(_ tag: Tag, to value: Any) {
        data.set(tag, to: value)
    }

    public func set(_ id: L, to value: @escaping () throws -> Any) { set(id[], to: value) }
    public func set(_ tag: Tag, to value: @escaping () throws -> Any) {
        data.set(tag, to: Data.Computed(key: tag, yield: value))
    }

    public func get(_ id: L) throws -> Any { try get(id[]) }
    public func get(_ tag: Tag) throws -> Any {
        try data.get(tag)
    }

    public func result(for id: L) -> Result<Any, Error> { result(for: id[]) }
    public func result(for tag: Tag) -> Result<Any, Error> {
        do {
            return try .success(get(tag))
        } catch let error as Error {
            return .failure(error)
        } catch {
            return .failure(.other(error))
        }
    }

    public func publisher(for id: L) -> AnyPublisher<Result<Any, Error>, Never> { publisher(for: id[]) }
    public func publisher(for tag: Tag) -> AnyPublisher<Result<Any, Error>, Never> {
        Just(result(for: tag))
            .merge(with: data.subject(for: tag))
            .eraseToAnyPublisher()
    }
}

extension Session.State.Data {

    public var isInTransaction: Bool { sync { dirty.level > 0 } }
    public var isNotInTransaction: Bool { !isInTransaction }

    func contains(_ key: Tag) -> Bool {
        sync { store.keys.contains(key) }
    }

    func get(_ key: Tag) throws -> Any {
        guard let value = sync(execute: { store[key] }) else {
            throw Session.State.Error.keyDoesNotExist(key)
        }
        return try (value as? Computed)?.yield() ?? value
    }

    func set(_ key: Tag, to value: Any) {
        sync {
            dirty.data[key] = value
            if isNotInTransaction {
                update([key: value])
            }
        }
    }

    func clear(_ key: Tag) {
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

    func subject(for key: Tag) -> Session.State.Subject {
        sync {
            let subject = subjects[key, default: .init()]
            subjects[key] = subject
            return subject
        }
    }

    private func update(_ data: [Tag: Any]) {
        sync {
            for (key, value) in data {
                switch value {
                case is Tombstone.Type:
                    store.removeValue(forKey: key)
                default:
                    store[key] = value
                }
            }
            for (key, value) in data {
                switch value {
                case is Tombstone.Type:
                    subjects[key]?.send(.failure(.keyDoesNotExist(key)))
                default:
                    subjects[key]?.send(.success(value))
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
    public typealias Subject = PassthroughSubject<Result<Any, Error>, Never>
}

extension Session.State.Error: Equatable {

    public static func == (lhs: Session.State.Error, rhs: Session.State.Error) -> Bool {
        switch (lhs, rhs) {
        case (.keyDoesNotExist(let l), .keyDoesNotExist(let r)):
            return l == r
        case (.other(let e1), .other(let e2)):
            return String(describing: e1) == String(describing: e2)
        default:
            return false
        }
    }
}

extension DispatchSpecificKey {
    convenience init<K>(_: K.Type = K.self, on queue: DispatchQueue) where T == K.Type {
        self.init()
        queue.setSpecific(key: self, value: K.self)
    }
}
