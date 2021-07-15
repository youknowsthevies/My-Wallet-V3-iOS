// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AuthenticationKit
import Combine
import RxSwift
import WalletPayloadKit

public final class TwoFAWalletService: TwoFAWalletServiceAPI {

    // MARK: - Type
    public typealias WalletRepositoryAPI = GuidRepositoryAPI & SessionTokenRepositoryAPI & PayloadRepositoryAPI

    // MARK: - Properties

    private let client: TwoFAWalletClientAPI
    private let repository: WalletRepositoryAPI

    // MARK: - Setup

    public init(client: TwoFAWalletClientAPI, repository: WalletRepositoryAPI) {
        self.client = client
        self.repository = repository
    }

    // MARK: - API

    public func send(code: String) -> Completable {
        // Trim whitespaces before verifying and sending
        let code = code.trimmingWhitespaces

        /// Verify the code is not empty to save network call
        guard !code.isEmpty else {
            return .error(TwoFAWalletServiceError.missingCode)
        }

        /// 1. Zip guid and session-token
        /// 2. Verify they have values
        /// 3. Send payload request using client
        /// 4. Validate the payload (by checking it is not empty) and cache it
        /// 5. Convert to `Completable`
        /// *. Errors along the way should be caught and mapped
        return Single
            .zip(repository.guid, repository.sessionToken)
            .map(weak: self) { (_, credentials) -> (guid: String, sessionToken: String) in
                guard let guid = credentials.0 else {
                    throw MissingCredentialsError.guid
                }
                guard let sessionToken = credentials.1 else {
                    throw MissingCredentialsError.sessionToken
                }
                return (guid, sessionToken)
            }
            .flatMap(weak: self) { (self, credentials) -> Single<WalletPayloadWrapper> in
                self.client.payload(guid: credentials.guid, sessionToken: credentials.sessionToken, code: code)
            }
            .flatMapCompletable(weak: self) { (self, response) -> Completable in
                guard let rawPayload = response.stringRepresentation, !rawPayload.isEmpty else {
                    throw TwoFAWalletServiceError.missingPayload
                }
                return self.repository.set(payload: rawPayload)
            }
            .catchError { error -> Completable in
                switch error {
                case TwoFAWalletClient.ClientError.wrongCode(attemptsLeft: let attempts):
                    throw TwoFAWalletServiceError.wrongCode(attemptsLeft: attempts)
                case TwoFAWalletClient.ClientError.accountLocked:
                    throw TwoFAWalletServiceError.accountLocked
                default:
                    throw error
                }
            }
    }
}

// MARK: - TwoFAWalletServiceCombineAPI

extension TwoFAWalletService {

    public func sendPublisher(code: String) -> AnyPublisher<Void, TwoFAWalletServiceError> {
        // Trim whitespaces before verifying and sending
        let code = code.trimmingWhitespaces

        /// Verify the code is not empty to save network call
        guard !code.isEmpty else {
            return .failure(.missingCode)
        }

        return repository.guidPublisher
            .zip(repository.sessionTokenPublisher)
            .setFailureType(to: TwoFAWalletServiceError.self)
            .flatMap { credentials -> AnyPublisher<(guid: String, sessionToken: String), TwoFAWalletServiceError> in
                guard let guid = credentials.0 else {
                    return .failure(.missingCredentials(.guid))
                }
                guard let sessionToken = credentials.1 else {
                    return .failure(.missingCredentials(.sessionToken))
                }
                return .just((guid, sessionToken))
            }
            .flatMap { [client] credentails -> AnyPublisher<WalletPayloadWrapper, TwoFAWalletServiceError> in
                client.payloadPublisher(guid: credentails.guid,
                                        sessionToken: credentails.sessionToken,
                                        code: code)
            }
            .flatMap { response -> AnyPublisher<String, TwoFAWalletServiceError> in
                guard let rawPayload = response.stringRepresentation, !rawPayload.isEmpty else {
                    return .failure(.missingPayload)
                }
                return .just(rawPayload)
            }
            .flatMap { [repository] rawPayload -> AnyPublisher<Void, TwoFAWalletServiceError> in
                repository.setPublisher(payload: rawPayload)
                    .mapError()
            }
            .catch { error -> AnyPublisher<Void, TwoFAWalletServiceError> in
                switch error {
                case .wrongCode(attemptsLeft: let attempts):
                    return .failure(.wrongCode(attemptsLeft: attempts))
                case .accountLocked:
                    return .failure(.accountLocked)
                default:
                    return .failure(error)
                }
            }
            .eraseToAnyPublisher()
    }
}
