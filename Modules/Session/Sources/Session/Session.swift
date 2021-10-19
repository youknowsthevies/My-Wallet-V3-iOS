// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation

public final class State<Key: Hashable> {

    var data = Data()

    public init(_ data: [Key: Any] = [:]) {
        self.data.store = data
    }
}

extension State {

    public class Data {

        public internal(set) var store: [Key: Any] = [:]
        internal var subjects: [Key: Subject] = [:]
        private var dirty: (data: [Key: Any], level: UInt) = ([:], 0)

        private var q: DispatchQueue = DispatchQueue(label: "com.blockchain.session.state.q")
        private var k: DispatchSpecificKey<Data.Type>

        init() { k = .init(on: q) }
    }

    public enum Error: Swift.Error {
        case keyDoesNotExist(Key)
        case typeMismatch(Key, expected: Any.Type, actual: Any.Type)
        case other(Swift.Error)
    }
}

extension State.Data {

    private struct Tombstone: Hashable {}

    public struct Computed {
        public let key: Key
        public let yield: () throws -> Any
    }
}

extension State {

    public func transaction<Ignored>(_ yield: (State) throws -> Ignored) {
        data.beginTransaction()
        do {
            _ = try yield(self)
            data.endTransaction()
        } catch {
            data.rollbackTransaction()
        }
    }

    public func contains(_ key: Key) -> Bool {
        data.store.keys.contains(key)
    }

    public func clear(_ key: Key) {
        data.clear(key)
    }

    public func set(_ key: Key, to value: Any) {
        data.set(key, to: value)
    }

    public func set(_ key: Key, to value: @escaping () throws -> Any) {
        data.set(key, to: Data.Computed(key: key, yield: value))
    }

    public func get<T>(_ key: Key, as _: T.Type = T.self) throws -> T {
        let _value = try get(key)
        guard let value = _value as? T else {
            throw Error.typeMismatch(key, expected: T.self, actual: type(of: _value))
        }
        return value
    }

    public func get(_ key: Key) throws -> Any {
        try data.get(key)
    }

    public func result<T>(for key: Key, as _: T.Type = T.self) -> Result<T, Error> {
        Self.map(result(for: key), to: T.self, for: key)
    }

    public func result(for key: Key) -> Result<Any, Error> {
        do {
            return try .success(get(key))
        } catch let error as Error {
            return .failure(error)
        } catch {
            return .failure(.other(error))
        }
    }

    public func publisher<T: Equatable>(for key: Key, as _: T.Type = T.self) -> AnyPublisher<Result<T, Error>, Never> {
        publisher(for: key)
            .map { result in
                Self.map(result, to: T.self, for: key)
            }
            .removeDuplicates(by: { a, b in
                switch (a, b) {
                case (.success(let a), .success(let b)):
                    return a == b
                case (.failure(.keyDoesNotExist(let a)), .failure(.keyDoesNotExist(let b))):
                    return a == b
                default:
                    return false
                }
            })
            .eraseToAnyPublisher()
    }

    public func publisher(for key: Key) -> AnyPublisher<Result<Any, Error>, Never> {
        Just(result(for: key))
            .merge(with: data.subject(for: key))
            .eraseToAnyPublisher()
    }

    private static func map<T>(_ result: Result<Any, Error>, to _: T.Type, for key: Key) -> Result<T, Error> {
        result.flatMap { value in
            guard let __ = value as? T else {
                return .failure(.typeMismatch(key, expected: T.self, actual: type(of: value)))
            }
            return .success(__)
        }
    }
}

extension State.Data {

    public var isInTransaction: Bool { sync { dirty.level > 0 } }
    public var isNotInTransaction: Bool { !isInTransaction }

    public func contains(_ key: Key) -> Bool {
        sync { store.keys.contains(key) }
    }

    func get(_ key: Key) throws -> Any {
        guard let value = sync(execute: { store[key] }) else {
            throw State.Error.keyDoesNotExist(key)
        }
        return try (value as? Computed)?.yield() ?? value
    }

    func set(_ key: Key, to value: Any) {
        sync {
            dirty.data[key] = value
            if isNotInTransaction {
                update([key: value])
            }
        }
    }

    func clear(_ key: Key) {
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

    func subject(for key: Key) -> State.Subject {
        sync {
            let subject = subjects[key, default: .init()]
            subjects[key] = subject
            return subject
        }
    }

    private func update(_ data: [Key: Any]) {
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
                    notify(key, with: Any?.none as Any)
                default:
                    notify(key, with: value)
                }
            }
        }
    }

    func notify(_ key: Key, with value: Any) {
        subjects[key]?.send(.success(value))
    }

    @discardableResult
    public func sync<T>(execute work: () throws -> T) rethrows -> T {
        DispatchQueue.getSpecific(key: k) == nil
            ? try q.sync(execute: work)
            : try work()
    }
}

extension State {
    public typealias Subject = PassthroughSubject<Result<Any, Error>, Never>
}

extension DispatchSpecificKey {
    convenience init<K>(_: K.Type = K.self, on queue: DispatchQueue) where T == K.Type {
        self.init()
        queue.setSpecific(key: self, value: K.self)
    }
}

extension State.Error: Equatable {

    public static func == (lhs: State.Error, rhs: State.Error) -> Bool {
        switch (lhs, rhs) {
        case (.keyDoesNotExist(let l), .keyDoesNotExist(let r)):
            return l == r
        case (.typeMismatch(let k1, let e1, let a1), .typeMismatch(let k2, let e2, let a2)):
            return k1 == k2
                && String(reflecting: e1) == String(reflecting: e2)
                && String(reflecting: a1) == String(reflecting: a2)
        case (.other(let e1), .other(let e2)):
            return String(describing: e1) == String(describing: e2)
        default:
            return false
        }
    }

}
