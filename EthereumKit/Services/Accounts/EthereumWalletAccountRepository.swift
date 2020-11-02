//
//  EthereumWalletAccountRepository.swift
//  EthereumKit
//
//  Created by Jack Pooley on 20/11/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import PlatformKit
import RxSwift
import ToolKit

protocol EthereumWalletAccountRepositoryAPI {
    
    var defaultAccount: Single<EthereumWalletAccount> { get }
    var accounts: Single<[EthereumWalletAccount]> { get }
    var activeAccounts: Single<[EthereumWalletAccount]> { get }
}

// TODO: Move everything over from `EthereumWalletAccountRepository` to `EthereumWalletAccountRepositoryNew`
final class EthereumWalletAccountRepository: EthereumWalletAccountRepositoryAPI, KeyPairProviderNewAPI {
    
    typealias KeyPair = EthereumKeyPair
    typealias Account = EthereumWalletAccount
    typealias Bridge = CompleteEthereumWalletBridgeAPI

    // MARK: - EthereumWalletAccountRepositoryAPI
    
    var defaultAccount: Single<Account> {
        bridge.account
            .map { assetAccount -> Account in
                Account(
                    index: assetAccount.walletIndex,
                    publicKey: assetAccount.accountAddress,
                    label: assetAccount.name,
                    archived: false
                )
            }
    }
    
    var accounts: Single<[Account]> {
        defaultAccount.map { [ $0 ] }
    }
    
    var activeAccounts: Single<[Account]> {
        accounts.map { accounts in
            accounts.filter(\.isActive)
        }
    }
    
    // MARK: - KeyPairProviderNewAPI
    
    var keyPair: Single<KeyPair> {
        bridge.mnemonicPromptingIfNeeded
            .flatMap(weak: self) { (self, mnemonic) -> Single<KeyPair> in
                self.deriver.derive(
                    input: EthereumKeyDerivationInput(
                        mnemonic: mnemonic,
                        password: ""
                    )
                )
                .single
            }
    }
    
    // MARK: - Private Properties
    
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
}

extension EthereumWalletAccount {
    var isActive: Bool {
        !archived
    }
}
