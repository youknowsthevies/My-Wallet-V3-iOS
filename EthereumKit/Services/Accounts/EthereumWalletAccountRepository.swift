//
//  EthereumWalletAccountRepository.swift
//  EthereumKit
//
//  Created by kevinwu on 2/6/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import PlatformKit
import RxSwift

public protocol EthereumWalletAccountRepositoryAPI {
    var keyPair: Maybe<EthereumKeyPair> { get }
    var defaultAccount: EthereumWalletAccount? { get }
    
    func initializeMetadataMaybe() -> Maybe<EthereumWalletAccount>
    func accounts() -> [EthereumWalletAccount]
}

open class EthereumWalletAccountRepository: EthereumWalletAccountRepositoryAPI, WalletAccountRepositoryAPI, KeyPairProviderAPI {
    public typealias Account = EthereumWalletAccount
    public typealias KeyPair = EthereumKeyPair
    public typealias WalletAccount = EthereumWalletAccount
    public typealias Bridge =
          EthereumWalletBridgeAPI
        & MnemonicAccessAPI
        & PasswordAccessAPI
        & EthereumWalletAccountBridgeAPI

    // MARK: - Properties
    
    public var keyPair: Maybe<KeyPair> {
        loadKeyPair()
    }

    // For ETH, there is only one account which is the default account.
    public var defaultAccount: EthereumWalletAccount?
    
    // MARK: - Private Properties
    
    private let disposeBag = DisposeBag()
    private let bridge: Bridge
    private let deriver: AnyKeyPairDeriver<EthereumKeyPair, EthereumKeyDerivationInput>
    
    // MARK: - Init
    
    convenience init(with bridge: Bridge = resolve()) {
        self.init(with: bridge, deriver: AnyEthereumKeyPairDeriver())
    }

    init<D: KeyPairDeriverAPI>(with bridge: Bridge, deriver: D) where D.Pair == EthereumKeyPair, D.Input == EthereumKeyDerivationInput {
        self.bridge = bridge
        self.deriver = AnyKeyPairDeriver<EthereumKeyPair, EthereumKeyDerivationInput>(deriver: deriver)
    }

    // MARK: - Public methods
    
    public func initializeMetadataMaybe() -> Maybe<WalletAccount> {
        loadDefaultAccount()
    }

    public func accounts() -> [WalletAccount] {
        guard let defaultAccount = defaultAccount else {
            return []
        }
        return [ defaultAccount ]
    }
    
    // MARK: - Private methods
    
    private func loadDefaultAccount() -> Maybe<WalletAccount> {
        bridge.wallets.asMaybe()
            .flatMap { accounts -> Maybe<WalletAccount> in
                guard let first = accounts.first else {
                    return Maybe.empty()
                }
                return Maybe.just(first)
            }
            .do(onNext: { account in
                self.defaultAccount = account
            })
    }
    
    // MARK: - KeyPairProviderAPI
    
    public func loadKeyPair() -> Maybe<KeyPair> {
        bridge.mnemonicPromptingIfNeeded
            .flatMap(weak: self) { (self, mnemonic) -> Maybe<KeyPair> in
                self.deriver.derive(input: EthereumKeyDerivationInput(mnemonic: mnemonic, password: "")).maybe
            }
    }

    private func save(keyPair: KeyPair) {
        // TODO: Need to localize this
        bridge.save(keyPair: keyPair, label: "My Ethereum Wallet")
            .subscribeOn(MainScheduler.asyncInstance)
            .observeOn(MainScheduler.instance)
            .subscribe()
            .disposed(by: disposeBag)
    }
}

extension EthereumWalletAccountRepository: WalletAccountInitializer { }
