//
//  SecondPasswordPromptable.swift
//  Blockchain
//
//  Created by Jack on 18/09/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import ToolKit
import RxSwift

enum SecondPasswordError: Error {
    case userDismissed
}

protocol SecondPasswordPromptable: class {
    var legacyWallet: LegacyWalletAPI? { get }
    var accountExists: Single<Bool> { get }
    
    var secondPasswordNeeded: Single<Bool> { get }
    var secondPasswordIfNeeded: Single<String?> { get }
    var promptForSecondPassword: Single<String> { get }
    var secondPasswordIfAccountCreationNeeded: Single<String?> { get }
}

extension SecondPasswordPromptable {
    
    @available(*, deprecated, message: "The implementation of second password prompting will be deprecated soon")
    var secondPasswordNeeded: Single<Bool> {
        guard let wallet = legacyWallet else {
            return Single.error(WalletError.notInitialized)
        }
        return Single.just(wallet.needsSecondPassword())
    }
    
    @available(*, deprecated, message: "The implementation of second password prompting will be deprecated soon")
    var secondPasswordIfNeeded: Single<String?> {
        secondPasswordNeeded
            .flatMap(weak: self) { (self, needed) -> Single<String?> in
                guard !needed else {
                    return self.promptForSecondPassword.optional()
                }
                return .just(nil)
            }
    }
    
    @available(*, deprecated, message: "The implementation of second password prompting will be deprecated soon")
    var promptForSecondPassword: Single<String> {
        Single.create { observer -> Disposable in
            AuthenticationCoordinator.shared
                .showPasswordScreen(
                    type: .actionRequiresPassword,
                    confirmHandler: { password in
                        observer(.success(password))
                    },
                    dismissHandler: {
                        observer(.error(SecondPasswordError.userDismissed))
                    }
                )
            return Disposables.create()
        }
        .subscribeOn(MainScheduler.instance)
    }
    
    @available(*, deprecated, message: "The implementation of second password prompting will be deprecated soon")
    var secondPasswordIfAccountCreationNeeded: Single<String?> {
        accountExists
            .flatMap(weak: self) { (self, accountExists) -> Single<String?> in
                guard accountExists else {
                    return self.secondPasswordIfNeeded
                }
                return .just(nil)
            }
    }
}
