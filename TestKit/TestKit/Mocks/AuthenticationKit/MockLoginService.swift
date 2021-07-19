// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import AuthenticationKit
import Combine
import RxSwift

final class MockLoginService: LoginServiceAPI {

    func login(walletIdentifier: String) -> Completable {
        .empty()
    }

    func login(walletIdentifier: String, code: String) -> Completable {
        .empty()
    }

    var authenticator: Observable<WalletAuthenticatorType> = .just(.standard)

    func loginPublisher(walletIdentifier: String) -> AnyPublisher<Void, LoginServiceError> {
        .just(())
    }

    func loginPublisher(walletIdentifier: String, code: String) -> AnyPublisher<Void, LoginServiceError> {
        .just(())
    }
}
