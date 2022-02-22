// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public enum FetchResult {
    case value(Any, Metadata)
    case error(Error, Metadata)
}

extension FetchResult {

    public enum Error: Swift.Error {
        case keyDoesNotExist(Tag.Reference)
        case state(Session.State.Error)
        case other(Swift.Error)
    }
}

extension FetchResult {

    public struct Metadata {
        public let tag: Tag.Reference
    }

    public var metadata: Metadata {
        switch self {
        case .value(_, let metadata), .error(_, let metadata):
            return metadata
        }
    }
}

extension FetchResult {

    public init(catching body: () throws -> Any, _ metadata: Metadata) {
        self.init(.init(catching: body), metadata)
    }

    public init<E: Swift.Error>(_ result: Result<Any, E>, _ metadata: Metadata) {
        switch result {
        case .success(let value):
            self = .value(value, metadata)
        case .failure(let error as FetchResult.Error):
            self = .error(error, metadata)
        case .failure(.keyDoesNotExist(let tag) as Session.State.Error):
            self = .error(.keyDoesNotExist(tag), metadata)
        case .failure(let error as Session.State.Error):
            self = .error(.state(error), metadata)
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

    public func metadata() -> FetchResult.Metadata {
        FetchResult.Metadata(tag: ref())
    }
}

extension Tag.Reference {

    public func metadata() -> FetchResult.Metadata {
        FetchResult.Metadata(tag: self)
    }
}
