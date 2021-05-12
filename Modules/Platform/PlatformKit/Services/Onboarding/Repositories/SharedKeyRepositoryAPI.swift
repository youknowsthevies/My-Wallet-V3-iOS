// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import RxSwift

public protocol SharedKeyRepositoryAPI: class {
    /// Streams `Bool` indicating whether the shared key is currently cached in the repo
    var hasSharedKey: Single<Bool> { get }
    
    /// Streams the cached shared key or `nil` if it is not cached
    var sharedKey: Single<String?> { get }
    
    /// Sets the shared key
    func set(sharedKey: String) -> Completable
}

public extension SharedKeyRepositoryAPI {
    var hasSharedKey: Single<Bool> {
        sharedKey
            .map { sharedKey in
                guard let sharedKey = sharedKey else { return false }
                return !sharedKey.isEmpty
            }
    }
    
    var sharedKeyPublisher: AnyPublisher<String?, Never> {
        sharedKey.asPublisher()
            .ignoreFailure()
    }
}

public protocol CredentialsRepositoryAPI: SharedKeyRepositoryAPI, GuidRepositoryAPI {
    var credentials: Single<(guid: String, sharedKey: String)> { get }
    
    func fetchCredentials() -> AnyPublisher<(guid: String, sharedKey: String), MissingCredentialsError>
}

extension CredentialsRepositoryAPI {
    
    public var credentials: Single<(guid: String, sharedKey: String)> {
        Single
            .zip(guid, sharedKey)
            .map { (guid, sharedKey) -> (guid: String, sharedKey: String) in
                guard let guid = guid else {
                    throw MissingCredentialsError.guid
                }
                guard let sharedKey = sharedKey else {
                    throw MissingCredentialsError.sharedKey
                }
                return (guid, sharedKey)
            }
    }
    
    public func fetchCredentials() -> AnyPublisher<(guid: String, sharedKey: String), MissingCredentialsError> {
        guidPublisher.zip(sharedKeyPublisher)
            .setFailureType(to: MissingCredentialsError.self)
            .flatMap { guid, sharedKey -> AnyPublisher<(guid: String, sharedKey: String), MissingCredentialsError> in
                guard let guid = guid else {
                    return .failure(.guid)
                }
                guard let sharedKey = sharedKey else {
                    return .failure(.guid)
                }
                return .just((guid, sharedKey))
            }
            .eraseToAnyPublisher()
    }
}
