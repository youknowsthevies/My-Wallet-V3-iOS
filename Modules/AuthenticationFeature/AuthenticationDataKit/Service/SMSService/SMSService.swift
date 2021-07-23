// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AuthenticationKit
import Combine
import RxSwift
import ToolKit

public final class SMSService: SMSServiceAPI {

    public typealias WalletRepositoryAPI = GuidRepositoryAPI & SessionTokenRepositoryAPI

    // MARK: - Properties

    private let client: SMSClientAPI
    private let repository: WalletRepositoryAPI

    public init(client: SMSClientAPI, repository: WalletRepositoryAPI) {
        self.repository = repository
        self.client = client
    }

    // MARK: - API

    public func request() -> Completable {
        Single
            .zip(repository.guid, repository.sessionToken)
            .map(weak: self) { _, credentials -> (guid: String, sessionToken: String) in
                guard let guid = credentials.0 else {
                    throw MissingCredentialsError.guid
                }
                guard let sessionToken = credentials.1 else {
                    throw MissingCredentialsError.sessionToken
                }
                return (guid, sessionToken)
            }
            .flatMapCompletable(weak: self) { (self, credentials) -> Completable in
                self.client.requestOTP(
                    sessionToken: credentials.sessionToken,
                    guid: credentials.guid
                )
            }
    }
}

// MARK: - SMSServiceCombineAPI

extension SMSService {

    public func requestPublisher() -> AnyPublisher<Void, SMSServiceError> {
        repository.guidPublisher
            .zip(repository.sessionTokenPublisher)
            .flatMap { credentials -> AnyPublisher<(guid: String, sessionToken: String), SMSServiceError> in
                guard let guid = credentials.0 else {
                    return .failure(.missingCredentials(.guid))
                }
                guard let sessionToken = credentials.1 else {
                    return .failure(.missingCredentials(.sessionToken))
                }
                return .just((guid, sessionToken))
            }
            .flatMap { [client] credentials -> AnyPublisher<Void, SMSServiceError> in
                client.requestOTPPublisher(
                    sessionToken: credentials.sessionToken,
                    guid: credentials.guid
                )
                .mapError(SMSServiceError.networkError)
                .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}
