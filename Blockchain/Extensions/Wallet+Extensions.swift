//
//  Wallet+Extensions.swift
//  Blockchain
//
//  Created by AlexM on 11/26/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import PlatformKit
import RxSwift
import StellarKit

/// `MnemonicAccessAPI` is part of the `bridge` that is used when injecting the `wallet` into
/// a `WalletAccountRepository`. This is how we check if the user needs to enter their
/// secondary password if their wallet is double encrypted.
extension Wallet: MnemonicAccessAPI {
    public var mnemonicPromptingIfNeeded: Maybe<Mnemonic> {
        let prompter: SecondPasswordPromptable = resolve()
        return prompter.secondPasswordIfNeeded(type: .actionRequiresPassword)
            .flatMap(weak: self) { (self, secondPassword) -> Single<Mnemonic> in
                self.mnemonic(with: secondPassword)
            }
            .asMaybe()
    }
    
    public func mnemonic(with secondPassword: String?) -> Single<Mnemonic> {
        Single.just(())
            .observeOn(MainScheduler.asyncInstance)
            .flatMap(weak: self) { (self, _) -> Single<Mnemonic> in
                var secondPassword = secondPassword
                if secondPassword?.isEmpty == true {
                    secondPassword = nil
                }
                if self.needsSecondPassword(), secondPassword == nil {
                    return .error(MnemonicAccessError.generic)
                }
                guard let mnemonic = self.getMnemonic(secondPassword) else {
                    return .error(MnemonicAccessError.generic)
                }
                return .just(mnemonic)
            }
    }

    public var mnemonic: Maybe<Mnemonic> {
        Maybe.just(())
            .observeOn(MainScheduler.asyncInstance)
            .flatMap(weak: self) { (self, _) -> Maybe<Mnemonic> in
                guard !self.needsSecondPassword() else {
                    return Maybe.empty()
                }
                guard let mnemonic = self.getMnemonic(nil) else {
                    return Maybe.empty()
                }
                return Maybe.just(mnemonic)
            }
    }
}
