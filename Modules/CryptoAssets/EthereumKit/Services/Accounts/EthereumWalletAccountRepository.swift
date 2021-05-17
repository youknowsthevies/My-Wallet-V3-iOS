// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformKit
import RxSwift
import ToolKit

protocol EthereumWalletAccountRepositoryAPI {

    var defaultAccount: Single<EthereumWalletAccount> { get }
    var accounts: Single<[EthereumWalletAccount]> { get }
    var activeAccounts: Single<[EthereumWalletAccount]> { get }
}

final class EthereumWalletAccountRepository: EthereumWalletAccountRepositoryAPI, KeyPairProviderAPI {

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

    // MARK: - KeyPairProviderAPI

    func keyPair(with secondPassword: String?) -> Single<EthereumKeyPair> {
        bridge.mnemonic(with: secondPassword)
            .flatMap(weak: self) { (self, mnemonic) -> Single<KeyPair> in
                self.deriver.derive(
                    input: EthereumKeyDerivationInput(
                        mnemonic: mnemonic
                    )
                )
                .single
            }
    }

    var keyPair: Single<KeyPair> {
        bridge.mnemonicPromptingIfNeeded
            .flatMap(weak: self) { (self, mnemonic) -> Single<KeyPair> in
                self.deriver.derive(
                    input: EthereumKeyDerivationInput(
                        mnemonic: mnemonic
                    )
                )
                .single
            }
    }

    // MARK: - Private Properties

    private let bridge: Bridge
    private let deriver: AnyEthereumKeyPairDeriver

    // MARK: - Init

    convenience init(with bridge: Bridge = resolve()) {
        self.init(with: bridge, deriver: AnyEthereumKeyPairDeriver(deriver: EthereumKeyPairDeriver()))
    }

    init(with bridge: Bridge, deriver: AnyEthereumKeyPairDeriver) {
        self.bridge = bridge
        self.deriver = deriver
    }
}

extension EthereumWalletAccount {
    var isActive: Bool {
        !archived
    }
}
