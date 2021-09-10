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
        var subjects: [Key: Subject] = [:]
        private var dirty: (data: [Key: Any], level: UInt) = ([:], 0)
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

    public func set(_ key: Key, to value:  @escaping () throws -> Any) {
        data.set(key, to: Data.Computed(key: key, yield: value))
    }

    public func get<T>(_ key: Key, as _: T.Type = T.self) throws -> T {
        let _value = try get(key)
        guard let value = _value as? T else {
            throw Error.typeMismatch(key, expected: T.self, actual: type(of: _value))
        }
        return value
    }

    private func get(_ key: Key) throws -> Any {
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
        publisher(for: key).map { result in
            Self.map(result, to: T.self, for: key)
        }.removeDuplicates(by: { a, b in
            switch (a, b) {
            case let (.success(a), .success(b)):
                return a == b
            case let (.failure(.keyDoesNotExist(a)), .failure(.keyDoesNotExist(b))):
                return a == b
            default:
                return false
            }
        }).eraseToAnyPublisher()
    }

    public func publisher(for key: Key) -> AnyPublisher<Result<Any, Error>, Never> {
        let subject = data.subjects[key, default: Subject()]
        defer { data.subjects[key] = subject }
        return Just(result(for: key))
            .merge(with: subject)
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

    public var isInTransaction: Bool { dirty.level > 0 }
    public var isNotInTransaction: Bool { !isInTransaction }

    func get(_ key: Key) throws -> Any {
        guard let value = store[key] else {
            throw State.Error.keyDoesNotExist(key)
        }
        return try (value as? Computed)?.yield() ?? value
    }

    func set(_ key: Key, to value: Any) {
        dirty.data[key] = value
        if isNotInTransaction {
            store[key] = value
            updateSubjects()
        }
    }

    func clear(_ key: Key) {
        if isInTransaction {
            dirty.data[key] = Tombstone.self
        } else {
            store[key] = nil
            updateSubjects()
        }
    }

    func beginTransaction() {
        dirty.level += 1
    }

    func endTransaction() {
        switch dirty.level {
        case 1:
            updateSubjects()
        case 1...UInt.max:
            dirty.level -= 1
        default:
            return assertionFailure("Misaligned begin -> end transaction calls. You must be in a transaction to end a transaction.")
        }
        dirty.data = [:]
    }

    func rollbackTransaction() {
        precondition(isInTransaction)
        dirty.level = 0
        dirty.data = [:]
    }

    func updateSubjects() {
        for (key, value) in dirty.data {
            switch value {
            case is Tombstone.Type:
                store.removeValue(forKey: key)
                notify(key, with: Optional<Any>.none as Any)
            default:
                store[key] = value
                notify(key, with: value)
            }
        }
        dirty.level = 0
        dirty.data.removeAll(keepingCapacity: true)
    }

    func notify(_ key: Key, with value: Any) {
        subjects[key]?.send(.success(value))
    }
}

extension State {
    public typealias Subject = PassthroughSubject<Result<Any, Error>, Never>
}
