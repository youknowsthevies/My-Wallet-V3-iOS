//
//  StellarWalletAccountRepository.swift
//  StellarKit
//
//  Created by Alex McGregor on 11/13/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxSwift

public protocol StellarWalletAccountRepositoryAPI {
    var defaultAccount: StellarWalletAccount? { get }
    
    func initializeMetadataMaybe() -> Maybe<StellarWalletAccount>
    func loadKeyPair() -> Maybe<StellarKeyPair>
}

open class StellarWalletAccountRepository: StellarWalletAccountRepositoryAPI, WalletAccountRepositoryAPI, WalletAccountInitializer, KeyPairProviderAPI {
    public typealias Account = StellarWalletAccount
    public typealias Pair = StellarKeyPair
    public typealias WalletAccount = StellarWalletAccount
    public typealias Bridge = StellarWalletBridgeAPI & MnemonicAccessAPI
    
    fileprivate let bridge: Bridge
    fileprivate let deriver: StellarKeyPairDeriver = StellarKeyPairDeriver()
    
    public init(with bridge: Bridge) {
        self.bridge = bridge
    }
    
    public func initializeMetadataMaybe() -> Maybe<WalletAccount> {
        loadDefaultAccount().ifEmpty(
            switchTo: createAndSaveStellarAccount()
        )
    }
    
    /// The default `StellarWallet`, will be nil if it has not yet been initialized
    open var defaultAccount: WalletAccount? {
        accounts().first
    }
    
    open func accounts() -> [WalletAccount] {
        bridge.stellarWallets()
    }
    
    public func loadKeyPair() -> Maybe<Pair> {
        bridge.mnemonicPromptingIfNeeded
            .flatMap { [unowned self] mnemonic -> Maybe<Pair> in
                self.deriver.derive(input: StellarKeyDerivationInput(mnemonic: mnemonic)).maybe
            }
    }
    
    // MARK: Private
    
    private func loadDefaultAccount() -> Maybe<WalletAccount> {
        guard let defaultAccount = defaultAccount else {
            return Maybe.empty()
        }
        return Maybe.just(defaultAccount)
    }
    
    private func createAndSaveStellarAccount() -> Maybe<WalletAccount> {
        loadKeyPair().do(onNext: { [unowned self] stellarKeyPair in
            self.save(keyPair: stellarKeyPair)
        })
        .map { keyPair -> Account in
            // TODO: Need to localize this
            return Account(
                index: 0,
                publicKey: keyPair.accountID,
                label: "My Stellar Wallet",
                archived: false
            )
        }
    }
    
    private func save(keyPair: Pair) {
        // TODO: Need to localize this
        bridge.save(keyPair: keyPair, label: "My Stellar Wallet") { errorMessage in
            // TODO: Need to localize this
            print(errorMessage ?? "")
        }
    }
}
