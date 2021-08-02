// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AuthenticationKit
import Combine
import RxRelay
import RxSwift

public final class LoginService: LoginServiceAPI {

    // MARK: - Properties

    public let authenticator: Observable<WalletAuthenticatorType>

    private let payloadService: WalletPayloadServiceAPI
    private let twoFAPayloadService: TwoFAWalletServiceAPI
    private let repository: GuidRepositoryAPI

    /// Keeps authenticator type. Defaults to `.none` unless
    /// `func login() -> Completable` sets it to a different value
    private let authenticatorRelay = BehaviorRelay(value: WalletAuthenticatorType.standard)

    // MARK: - Setup

    public init(
        payloadService: WalletPayloadServiceAPI,
        twoFAPayloadService: TwoFAWalletServiceAPI,
        repository: GuidRepositoryAPI
    ) {
        self.payloadService = payloadService
        self.twoFAPayloadService = twoFAPayloadService
        self.repository = repository
        authenticator = authenticatorRelay.asObservable()
    }

    // MARK: - API

    public func login(walletIdentifier: String) -> Completable {
        /// Set the wallet identifier as `GUID`
        repository
            .set(guid: walletIdentifier)
            .andThen(payloadService.requestUsingSessionToken())
            .catchError { error -> Single<WalletAuthenticatorType> in
                switch error {
                case WalletPayloadServiceError.accountLocked:
                    throw LoginServiceError.walletPayloadServiceError(.accountLocked)
                case WalletPayloadServiceError.message(let message):
                    throw LoginServiceError.walletPayloadServiceError(.message(message))
                default:
                    throw error
                }
            }
            // We have to keep the authenticator type
            // in case backend requires a 2FA OTP
            .do(onSuccess: { [weak authenticatorRelay] type in
                authenticatorRelay?.accept(type)
            })
            .flatMap { type -> Single<Void> in
                switch type {
                case .standard:
                    return .just(())
                default:
                    throw LoginServiceError.twoFactorOTPRequired(type)
                }
            }
            .asCompletable()
    }

    public func login(walletIdentifier: String, code: String) -> Completable {
        twoFAPayloadService
            .send(code: code)
            .catchError { error -> Completable in
                switch error {
                case TwoFAWalletServiceError.wrongCode(attemptsLeft: let attempts):
                    throw LoginServiceError.twoFAWalletServiceError(.wrongCode(attemptsLeft: attempts))
                case TwoFAWalletServiceError.accountLocked:
                    throw LoginServiceError.twoFAWalletServiceError(.accountLocked)
                default:
                    throw error
                }
            }
    }
}

// MARK: - LoginServiceCombineAPI

extension LoginService {

    public func loginPublisher(walletIdentifier: String) -> AnyPublisher<Void, LoginServiceError> {
        repository
            .setPublisher(guid: walletIdentifier)
            .flatMap { [payloadService] _ -> AnyPublisher<WalletAuthenticatorType, WalletPayloadServiceError> in
                payloadService.requestUsingSessionTokenPublisher()
            }
            .mapError(LoginServiceError.walletPayloadServiceError)
            .handleEvents(receiveOutput: { [weak authenticatorRelay] type in
                authenticatorRelay?.accept(type)
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

    public func loginPublisher(walletIdentifier: String, code: String) -> AnyPublisher<Void, LoginServiceError> {
        twoFAPayloadService
            .sendPublisher(code: code)
            .mapError(LoginServiceError.twoFAWalletServiceError)
            .eraseToAnyPublisher()
    }
}
