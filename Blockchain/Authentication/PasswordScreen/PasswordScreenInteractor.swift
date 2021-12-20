// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import FeatureAppUI
import RxRelay
import RxSwift
import WalletPayloadKit

protocol PasswordScreenInteracting: AnyObject {
    var type: PasswordScreenType { get }
    var passwordRelay: CurrentValueSubject<String, Never> { get }
    var isValid: AnyPublisher<Bool, Never> { get }
}

final class PasswordScreenInteractor: PasswordScreenInteracting {

    // MARK: - Exposed Properties

    let passwordRelay = CurrentValueSubject<String, Never>("")
    let type: PasswordScreenType

    // MARK: - Injected

    private let wallet: Wallet
    private let secondPasswordService: SecondPasswordServiceAPI

    // MARK: - Setup

    init(
        type: PasswordScreenType,
        wallet: Wallet = WalletManager.shared.wallet,
        secondPasswordService: SecondPasswordServiceAPI = DIKit.resolve()
    ) {
        self.type = type
        self.wallet = wallet
        self.secondPasswordService = secondPasswordService
    }

    // MARK: - API

    var isValid: AnyPublisher<Bool, Never> {
        switch type {
        case .importPrivateKey:
            return .just(true)
        case .actionRequiresPassword, .etherService, .login:
            return nativeWalletFlagEnabled()
                .map { [passwordRelay] in ($0, passwordRelay.value) }
                .map { [secondPasswordService, wallet] isEnabled, secondPassword -> Bool in
                    guard isEnabled else {
                        return wallet.validateSecondPassword(secondPassword)
                    }
                    return secondPasswordService.validate(secondPassword: secondPassword)
                }
                .eraseToAnyPublisher()
        }
    }
}
