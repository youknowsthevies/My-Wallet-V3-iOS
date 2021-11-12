// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import FeatureAuthenticationDomain
import ToolKit
import WalletPayloadKit

public final class SMSService: SMSServiceAPI {

    public typealias WalletRepositoryAPI = GuidRepositoryAPI & SessionTokenRepositoryAPI

    // MARK: - Properties

    private let client: SMSClientAPI
    private let repository: WalletRepositoryAPI
    private let walletRepo: WalletRepo
    private let nativeWalletFlagEnabled: () -> AnyPublisher<Bool, Never>

    public init(
        client: SMSClientAPI,
        repository: WalletRepositoryAPI,
        walletRepo: WalletRepo,
        nativeWalletFlagEnabled: @escaping () -> AnyPublisher<Bool, Never>
    ) {
        self.repository = repository
        self.client = client
        self.walletRepo = walletRepo
        self.nativeWalletFlagEnabled = nativeWalletFlagEnabled
    }

    // MARK: - API

    public func request() -> AnyPublisher<Void, SMSServiceError> {
        let walletRepo = self.walletRepo
        let repository = self.repository

        let credentials = nativeWalletFlagEnabled()
            .flatMap { isEnabled -> AnyPublisher<(guid: String?, sessionToken: String?), SMSServiceError> in
                guard isEnabled else {
                    return repository.guidPublisher
                        .zip(repository.sessionTokenPublisher) { ($0, $1) }
                        .mapError()
                }
                return walletRepo.credentials
                    .map { ($0.guid, $0.sessionToken) }
                    .mapError()
            }
            .eraseToAnyPublisher()

        return credentials
            .flatMap { credentials -> AnyPublisher<(guid: String, sessionToken: String), SMSServiceError> in
                guard let guid = credentials.guid else {
                    return .failure(.missingCredentials(.guid))
                }
                guard let sessionToken = credentials.sessionToken else {
                    return .failure(.missingCredentials(.sessionToken))
                }
                return .just((guid, sessionToken))
            }
            .flatMap { [client] credentials -> AnyPublisher<Void, SMSServiceError> in
                client.requestOTP(
                    sessionToken: credentials.sessionToken,
                    guid: credentials.guid
                )
                .mapError(SMSServiceError.networkError)
                .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}
