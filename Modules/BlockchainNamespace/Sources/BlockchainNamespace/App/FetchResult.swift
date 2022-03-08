// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public enum FetchResult {
    case value(Any, Metadata)
    case error(FetchResult.Error, Metadata)
}

extension FetchResult {

    public enum Error: Swift.Error {
        case keyDoesNotExist(Tag.Reference)
        case other(Swift.Error)
    }
}

public struct Metadata {
    public let tag: Tag.Reference
    public let source: Source
}

extension Metadata {

    public enum Source {
        case undefined
        case state
        case remoteConfiguration
    }
}

extension FetchResult {

    public var metadata: Metadata {
        switch self {
        case .value(_, let metadata), .error(_, let metadata):
            return metadata
        }
    }

    public var value: Any? {
        switch self {
        case .value(let any, _):
            return any
        case .error:
            return nil
        }
    }

    public var error: FetchResult.Error? {
        switch self {
        case .error(let error, _):
            return error
        case .value:
            return nil
        }
    }

    public init(_ any: Any, metadata: Metadata) {
        self = .value(any, metadata)
    }

    public init(_ error: Error, metadata: Metadata) {
        self = .error(error, metadata)
    }

    public init(catching body: () throws -> Any, _ metadata: Metadata) {
        self.init(.init(catching: body), metadata)
    }

    public init<E: Swift.Error>(_ result: Result<Any, E>, _ metadata: Metadata) {
        switch result {
        case .success(let value):
            self = .value(value, metadata)
        case .failure(let error as FetchResult.Error):
            self = .error(error, metadata)
        case .failure(let error):
            self = .error(.other(error), metadata)
        }
    }

    public static func create<E: Swift.Error>(
        _ metadata: Metadata
    ) -> (
        _ result: Result<Any, E>
    ) -> FetchResult {
        { result in FetchResult(result, metadata) }
    }

    public static func create(
        _ metadata: Metadata
    ) -> (
        _ result: Any?
    ) -> FetchResult {
        { result in
            if let any = result {
                return .value(any, metadata)
            } else {
                return .error(.keyDoesNotExist(metadata.tag), metadata)
            }
        }
    }
}

extension Tag {

    public func metadata(_ source: Metadata.Source = .undefined) -> Metadata {
        Metadata(tag: ref(), source: source)
    }
}

extension Tag.Reference {

    public func metadata(_ source: Metadata.Source = .undefined) -> Metadata {
        Metadata(tag: self, source: source)
    }
}

public protocol DecodedFetchResult {

    associatedtype Value: Decodable

    var identity: FetchResult.Value<Value> { get }

    static func value(_ value: Value, _ metatata: Metadata) -> Self
    static func error(_ error: FetchResult.Error, _ metatata: Metadata) -> Self

    func get() throws -> Value
}

extension FetchResult {

    typealias Decoded = DecodedFetchResult

    public enum Value<T: Decodable>: DecodedFetchResult {
        case value(T, Metadata)
        case error(FetchResult.Error, Metadata)
    }

    public func decode<T: Decodable>(
        as type: T.Type = T.self,
        decoder: AnyDecoderProtocol = BlockchainNamespaceDecoder()
    ) -> Value<T> {
        do {
            switch self {
            case .value(let value, let metadata):
                return .value(try decoder.decode(T.self, from: value), metadata)
            case .error(let error, _):
                throw error
            }
        } catch let error as FetchResult.Error {
            return .error(error, metadata)
        } catch {
            return .error(.other(error), metadata)
        }
    }

    public var result: Result<Any, FetchResult.Error> {
        switch self {
        case .value(let value, _):
            return .success(value)
        case .error(let error, _):
            return .failure(error)
        }
    }

    public func get() throws -> Any {
        try result.get()
    }
}

extension FetchResult.Value {
    public var identity: FetchResult.Value<T> { self }
}

extension DecodedFetchResult {

    public var value: Value? {
        switch identity {
        case .value(let value, _):
            return value
        case .error:
            return nil
        }
    }

    public var error: FetchResult.Error? {
        switch identity {
        case .error(let error, _):
            return error
        case .value:
            return nil
        }
    }

    public var result: Result<Value, FetchResult.Error> {
        switch identity {
        case .value(let value, _):
            return .success(value)
        case .error(let error, _):
            return .failure(error)
        }
    }

    public func get() throws -> Value {
        try result.get()
    }
}

#if canImport(Combine)

import Combine

extension Publisher where Output == FetchResult {

    public func decode<T>(
        as _: T.Type = T.self,
        using decoder: AnyDecoderProtocol = BlockchainNamespaceDecoder()
    ) -> AnyPublisher<FetchResult.Value<T>, Failure> {
        map { result in result.decode(as: T.self, decoder: decoder) }
            .eraseToAnyPublisher()
    }
}

extension Publisher where Output: DecodedFetchResult {

    public func replaceError(
        with value: Output.Value
    ) -> AnyPublisher<Output.Value, Failure> {
        flatMap { output -> Just<Output.Value> in
            switch output.result {
            case .failure:
                return Just(value)
            case .success(let value):
                return Just(value)
            }
        }
        .eraseToAnyPublisher()
    }
}

#endif

extension Dictionary where Key == Tag {

    public func decode<T: Decodable>(
        _ key: L,
        as type: T.Type = T.self,
        using decoder: AnyDecoderProtocol = BlockchainNamespaceDecoder()
    ) throws -> T {
        try decode(key[], as: T.self, using: decoder)
    }

    public func decode<T: Decodable>(
        _ key: Tag,
        as type: T.Type = T.self,
        using decoder: AnyDecoderProtocol = BlockchainNamespaceDecoder()
    ) throws -> T {
        try FetchResult.value(self[key] as Any, key.metadata())
            .decode(as: T.self, decoder: decoder)
            .get()
    }
}

extension Optional where Wrapped == Any {

    public func decode<T: Decodable>(
        as type: T.Type = T.self,
        using decoder: AnyDecoderProtocol = BlockchainNamespaceDecoder()
    ) throws -> T {
        try decoder.decode(T.self, from: self as Any)
    }
}
