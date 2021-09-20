// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import PlatformKit
import RxSwift
import ToolKit

public enum WalletAccountRepositoryError: Error {
    case missingWallet
    case failedToFetchAccount(Error)
}

public protocol EthereumWalletAccountRepositoryAPI {

    var defaultAccount: AnyPublisher<EthereumWalletAccount, WalletAccountRepositoryError> { get }
}

final class EthereumWalletAccountRepository: EthereumWalletAccountRepositoryAPI, KeyPairProviderAPI {

    // MARK: - Types

    private struct Key: Hashable {}

    enum RepositoryError: Error {
        case failedToFetchAccount(Error)
    }

    typealias KeyPair = EthereumKeyPair
    typealias Account = EthereumWalletAccount

    // MARK: - EthereumWalletAccountRepositoryAPI

    var defaultAccount: AnyPublisher<EthereumWalletAccount, WalletAccountRepositoryError> {
        cachedValue.get(key: Key())
    }

    // MARK: - KeyPairProviderAPI

    func keyPair(with secondPassword: String?) -> Single<EthereumKeyPair> {
        mnemonicAccess
            .mnemonic(with: secondPassword)
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
        mnemonicAccess
            .mnemonicPromptingIfNeeded
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

    private let mnemonicAccess: MnemonicAccessAPI
    private let accountBridge: EthereumWalletAccountBridgeAPI
    private let deriver: AnyEthereumKeyPairDeriver
    private let cachedValue: CachedValueNew<
        Key,
        EthereumWalletAccount,
        WalletAccountRepositoryError
    >

    // MARK: - Init

    convenience init(
        mnemonicAccess: MnemonicAccessAPI = resolve(),
        accountBridge: EthereumWalletAccountBridgeAPI = resolve()
    ) {
        self.init(
            mnemonicAccess: mnemonicAccess,
            accountBridge: accountBridge,
            deriver: AnyEthereumKeyPairDeriver(deriver: EthereumKeyPairDeriver())
        )
    }

    init(
        mnemonicAccess: MnemonicAccessAPI,
        accountBridge: EthereumWalletAccountBridgeAPI,
        deriver: AnyEthereumKeyPairDeriver
    ) {
        self.mnemonicAccess = mnemonicAccess
        self.accountBridge = accountBridge
        self.deriver = deriver

        let cache: AnyCache<Key, EthereumWalletAccount> = InMemoryCache(
            configuration: .onLoginLogout(),
            refreshControl: PerpetualCacheRefreshControl()
        ).eraseToAnyCache()
        cachedValue = CachedValueNew(
            cache: cache,
            fetch: { [accountBridge] _ in
                accountBridge.wallets
                    .eraseError()
                    .map(\.first)
                    .mapError(WalletAccountRepositoryError.failedToFetchAccount)
                    .onNil(.missingWallet)
                    .map { account in
                        EthereumWalletAccount(
                            index: account.index,
                            publicKey: account.publicKey,
                            label: account.label,
                            archived: account.archived
                        )
                    }
                    .eraseToAnyPublisher()
            }
        )
    }
}
