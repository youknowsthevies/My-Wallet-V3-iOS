// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import AuthenticationKit
import Combine
import RxSwift

final class MockLoginService: LoginServiceAPI {

    /// Change this to adjust the mock service behaviour
    public var twoFAType: WalletAuthenticatorType = .standard

    func login(walletIdentifier: String) -> Completable {
        .empty()
    }

    func login(walletIdentifier: String, code: String) -> Completable {
        .empty()
    }

    var authenticator: Observable<WalletAuthenticatorType> = .just(.standard)

    func loginPublisher(walletIdentifier: String) -> AnyPublisher<Void, LoginServiceError> {
        switch twoFAType {
        case .standard:
            return .just(())
        case .yubiKey:
            return .failure(.twoFactorOTPRequired(.yubiKey))
        case .email:
            return .failure(.twoFactorOTPRequired(.email))
        case .yubikeyMtGox:
            return .failure(.twoFactorOTPRequired(.yubikeyMtGox))
        case .google:
            return .failure(.twoFactorOTPRequired(.google))
        case .sms:
            return .failure(.twoFactorOTPRequired(.sms))
        }
    }

    func loginPublisher(walletIdentifier: String, code: String) -> AnyPublisher<Void, LoginServiceError> {
        .just(())
    }
}
