// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import FeatureAuthenticationDomain
import WalletPayloadKit

public final class LoginService: LoginServiceAPI {

    // MARK: - Properties

    public let authenticator: AnyPublisher<WalletAuthenticatorType, Never>

    private let payloadService: WalletPayloadServiceAPI
    private let twoFAPayloadService: TwoFAWalletServiceAPI
    private let repository: GuidRepositoryAPI
    private let walletRepo: WalletRepo
    private let nativeWalletFlagEnabled: () -> AnyPublisher<Bool, Never>

    /// Keeps authenticator type. Defaults to `.none` unless
    /// `func login() -> AnyPublisher<Void, LoginServiceError>` sets it to a different value
    private let authenticatorSubject: CurrentValueSubject<WalletAuthenticatorType, Never>

    // MARK: - Setup

    public init(
        payloadService: WalletPayloadServiceAPI,
        twoFAPayloadService: TwoFAWalletServiceAPI,
        repository: GuidRepositoryAPI,
        walletRepo: WalletRepo,
        nativeWalletFlagEnabled: @escaping () -> AnyPublisher<Bool, Never>
    ) {
        self.payloadService = payloadService
        self.twoFAPayloadService = twoFAPayloadService
        self.repository = repository
        self.walletRepo = walletRepo
        self.nativeWalletFlagEnabled = nativeWalletFlagEnabled

        authenticatorSubject = CurrentValueSubject(WalletAuthenticatorType.standard)
        authenticator = authenticatorSubject.eraseToAnyPublisher()
    }

    // MARK: - API

    public func login(walletIdentifier: String) -> AnyPublisher<Void, LoginServiceError> {
        let repository = repository
        let walletRepo = walletRepo

        let setWalletIdentifierMethod: (String) -> AnyPublisher<Void, Never> = { [weak self] identifier in
            guard let self = self else {
                return .just(())
            }
            return self.nativeWalletFlagEnabled()
                .flatMap { isEnabled -> AnyPublisher<Void, Never> in
                    guard isEnabled else {
                        return repository.setPublisher(guid: identifier)
                    }
                    return walletRepo.set(keyPath: \.credentials.guid, value: identifier)
                        .mapToVoid()
                }
                .eraseToAnyPublisher()
        }

        return setWalletIdentifierMethod(walletIdentifier)
            .flatMap { [payloadService] _ -> AnyPublisher<WalletAuthenticatorType, WalletPayloadServiceError> in
                payloadService.requestUsingSessionToken()
            }
            .mapError(LoginServiceError.walletPayloadServiceError)
            .handleEvents(receiveOutput: { [authenticatorSubject] type in
                authenticatorSubject.send(type)
            })
            .flatMap { type -> AnyPublisher<Void, LoginServiceError> in
                switch type {
                case .standard:
                    return .just(())
                case .google, .yubiKey, .email, .yubikeyMtGox, .sms:
                    return .failure(.twoFactorOTPRequired(type))
                }
            }
            .eraseToAnyPublisher()
    }

    public func login(walletIdentifier: String, code: String) -> AnyPublisher<Void, LoginServiceError> {
        twoFAPayloadService
            .send(code: code)
            .mapError(LoginServiceError.twoFAWalletServiceError)
            .eraseToAnyPublisher()
    }
}
