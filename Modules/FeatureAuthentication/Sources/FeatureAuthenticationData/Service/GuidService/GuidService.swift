// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import FeatureAuthenticationDomain
import WalletPayloadKit

public final class GuidService: GuidServiceAPI {

    // MARK: - Properties

    /// Fetches the `GUID`
    public let guid: AnyPublisher<String, GuidServiceError>

    private let sessionTokenRepository: SessionTokenRepositoryAPI
    private let client: GuidClientAPI
    private let walletRepo: WalletRepo
    private let nativeWalletFlagEnabled: () -> AnyPublisher<Bool, Never>

    // MARK: - Setup

    public init(
        sessionTokenRepository: SessionTokenRepositoryAPI,
        client: GuidClientAPI,
        walletRepo: WalletRepo,
        nativeWalletFlagEnabled: @escaping () -> AnyPublisher<Bool, Never>
    ) {
        self.sessionTokenRepository = sessionTokenRepository
        self.client = client
        self.walletRepo = walletRepo
        self.nativeWalletFlagEnabled = nativeWalletFlagEnabled

        guid = nativeWalletFlagEnabled()
            .flatMap { isEnabled -> AnyPublisher<String?, GuidServiceError> in
                guard isEnabled else {
                    return sessionTokenRepository.sessionTokenPublisher
                        .mapError()
                }
                return walletRepo.credentials
                    .map { creds in
                        guard !creds.sessionToken.isEmpty else {
                            return nil
                        }
                        return creds.sessionToken
                    }
                    .mapError()
            }
            .flatMap { [client] token -> AnyPublisher<String?, GuidServiceError> in
                guard let token = token else {
                    return .failure(.missingSessionToken)
                }
                return client.guid(by: token)
                    .mapError(GuidServiceError.networkError)
                    .eraseToAnyPublisher()
            }
            .flatMap { guidOrNil -> AnyPublisher<String, GuidServiceError> in
                guard let guid = guidOrNil else {
                    return .failure(.missingGuid)
                }
                return .just(guid)
            }
            .share()
            .eraseToAnyPublisher()
    }
}
