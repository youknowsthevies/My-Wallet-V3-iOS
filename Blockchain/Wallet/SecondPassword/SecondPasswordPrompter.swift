//
//  SecondPasswordPrompter.swift
//  Blockchain
//
//  Created by Jack on 18/09/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import RxSwift
import ToolKit

enum SecondPasswordError: Error {
    case userDismissed
}

protocol SecondPasswordPromptable: AnyObject {
    func secondPasswordIfNeeded(type: PasswordScreenType) -> Single<String?>
}

final class SecondPasswordPrompter: SecondPasswordPromptable {

    private let secondPasswordStore: SecondPasswordStorable
    @LazyInject private var walletManager: WalletManager

    init(secondPasswordStore: SecondPasswordStorable = resolve()) {
        self.secondPasswordStore = secondPasswordStore
    }

    func secondPasswordIfNeeded(type: PasswordScreenType) -> Single<String?> {
        secondPasswordNeeded
            .flatMap(weak: self) { (self, needed) -> Single<String?> in
                guard needed else {
                    return .just(nil)
                }
                guard let secondPassword = self.secondPasswordStore.secondPassword.value else {
                    return self.promptForSecondPassword(type: type).optional()
                }
                return .just(secondPassword)
            }
    }

    private func promptForSecondPassword(type: PasswordScreenType) -> Single<String> {
        Single.create { [weak self] observer -> Disposable in
            AuthenticationCoordinator.shared
                .showPasswordScreen(
                    type: type,
                    confirmHandler: { [weak self] secondPassword in
                        self?.secondPasswordStore.secondPassword.mutate { $0 = secondPassword }
                        observer(.success(secondPassword))
                    },
                    dismissHandler: {
                        observer(.error(SecondPasswordError.userDismissed))
                    }
                )
            return Disposables.create()
        }
        .subscribeOn(MainScheduler.asyncInstance)
    }

    private var secondPasswordNeeded: Single<Bool> {
        Single.create(weak: self) { (self, observer) -> Disposable in
            let wallet = self.walletManager.wallet
            switch wallet.isInitialized() {
            case false:
                observer(.error(WalletError.notInitialized))
            case true:
                observer(.success(wallet.needsSecondPassword()))
            }
            return Disposables.create()
        }
        .subscribeOn(MainScheduler.asyncInstance)
    }
}
