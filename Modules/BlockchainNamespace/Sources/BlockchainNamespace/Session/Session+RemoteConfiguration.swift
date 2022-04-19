// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import FirebaseProtocol
import Foundation

extension Session {

    public class RemoteConfiguration {

        public var isSynchronized: Bool { _isSynchronized.value }
        private let _isSynchronized: CurrentValueSubject<Bool, Never> = .init(false)

        public var allKeys: [String] { Array(fetched.keys) }

        private var fetched: [String: Any] {
            get { _fetched.value }
            set { _fetched.send(newValue) }
        }

        private var _fetched: CurrentValueSubject<[String: Any], Never> = .init([:])
        private var fetch: ((AppProtocol, Bool) -> Void)?
        private var bag: Set<AnyCancellable> = []

        public init<Remote: RemoteConfiguration_p>(
            remote: Remote,
            default defaultValue: Tag.Context = [:]
        ) {
            fetch = { [unowned self] app, isStale in
                Task {
                    var configuration: [String: Any] = defaultValue.dictionary.mapKeys { key in
                        key.idToFirebaseConfigurationKeyDefault()
                    }

                    let expiration: TimeInterval
                    if isStale {
                        expiration = 0 // Instant
                    } else if isDebug {
                        expiration = 30 // 30 seconds
                    } else {
                        expiration = 3600 // 1 hour
                    }

                    do {
                        let status = try await remote.fetch(withExpirationDuration: expiration)
                        _ = try await remote.activate()
                    } catch {
                        print("😱", "unable to fetch remote configuration", error)
                        #if DEBUG
                        fatalError(String(describing: error))
                        #endif
                    }

                    let keys = remote.allKeys(from: .remote)
                    for key in keys {
                        do {
                            configuration[key] = try JSONSerialization.jsonObject(
                                with: remote[key].dataValue,
                                options: .fragmentsAllowed
                            )
                        } catch {
                            configuration[key] = String(decoding: remote[key].dataValue, as: UTF8.self)
                        }
                    }

                    _fetched.send(configuration)
                    _isSynchronized.send(true)
                    app.state.set(blockchain.app.configuration.remote.is.stale, to: false)
                }
            }
        }

        func start(app: AppProtocol) {
            app.publisher(for: blockchain.app.configuration.remote.is.stale, as: Bool.self)
                .replaceError(with: false)
                .scan((stale: false, count: 0)) { ($1, $0.count + 1) }
                .sink { [unowned self] stale, count in
                    if stale || count == 1 {
                        fetch?(app, stale)
                    }
                }
                .store(in: &bag)
        }

        public func override(_ key: Tag.Reference, with value: Any) {
            fetched[key.idToFirebaseConfigurationKeyImportant()] = value
        }

        public func clear(_ key: Tag.Reference) {
            fetched.removeValue(forKey: key.idToFirebaseConfigurationKeyImportant())
        }

        public func get(_ key: Tag.Reference) throws -> Any {
            guard isSynchronized else { throw Error.notSynchronized }
            guard let value = fetched[firstOf: key.firebaseConfigurationKeys] else {
                throw Error.keyDoesNotExist(key)
            }
            return value
        }

        public func result(for key: Tag.Reference) -> FetchResult {
            guard isSynchronized else {
                return .error(.other(Error.notSynchronized), key.metadata(.remoteConfiguration))
            }
            guard let value = fetched[firstOf: key.firebaseConfigurationKeys] else {
                return .error(.keyDoesNotExist(key), key.metadata(.remoteConfiguration))
            }
            return .value(value, key.metadata(.remoteConfiguration))
        }

        public func publisher(for key: Tag.Reference) -> AnyPublisher<FetchResult, Never> {
            _isSynchronized
                .combineLatest(_fetched)
                .filter(\.0)
                .map(\.1)
                .flatMap { configuration -> Just<FetchResult> in
                    switch configuration[firstOf: key.firebaseConfigurationKeys] {
                    case let value?:
                        return Just(.value(value, key.metadata(.remoteConfiguration)))
                    case nil:
                        return Just(.error(.keyDoesNotExist(key), key.metadata(.remoteConfiguration)))
                    }
                }
                .eraseToAnyPublisher()
        }

        public func publisher(for string: String) -> AnyPublisher<Any?, Never> {
            _isSynchronized
                .combineLatest(_fetched)
                .filter(\.0)
                .map(\.1)
                .map { configuration -> Any? in configuration[string] }
                .eraseToAnyPublisher()
        }

        /// Determines if the app has the `DEBUG` build flag.
        private var isDebug: Bool {
            #if DEBUG
            return true
            #else
            return false
            #endif
        }
    }
}

extension Session.RemoteConfiguration {

    public enum Error: Swift.Error {
        case notSynchronized
        case keyDoesNotExist(Tag.Reference)
    }
}

extension Tag.Reference {

    fileprivate var components: [String] {
        tag.lineage.reversed().flatMap { tag -> [String] in
            guard
                let collectionId = try? tag.as(blockchain.db.collection).id[],
                let id = indices[collectionId]
            else {
                return [tag.name]
            }
            return [tag.name, id.description]
        }
    }

    fileprivate var firebaseConfigurationKeys: [String] {
        [
            idToFirebaseConfigurationKeyImportant(),
            idToFirebaseConfigurationKey(),
            idToFirebaseConfigurationKeyFallback(),
            idToFirebaseConfigurationKeyDefault()
        ]
    }

    fileprivate func idToFirebaseConfigurationKeyImportant() -> String { "!" + string }
    fileprivate func idToFirebaseConfigurationKeyDefault() -> String { string }

    fileprivate func idToFirebaseConfigurationKey() -> String {
        components.joined(separator: "_")
    }

    fileprivate func idToFirebaseConfigurationKeyFallback() -> String {
        idToFirebaseConfigurationKey()
            .replacingOccurrences(
                of: "blockchain_app_configuration",
                with: "ios_ff"
            )
    }
}

extension Dictionary {

    fileprivate subscript(firstOf first: Key, _ rest: Key...) -> Value? {
        self[firstOf: [first] + rest]
    }

    fileprivate subscript(firstOf keys: [Key]) -> Value? {
        for key in keys {
            guard let value = self[key] else { continue }
            return value
        }
        return nil
    }
}
