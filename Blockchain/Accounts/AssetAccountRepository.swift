// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformKit
import RxSwift
import StellarKit
import ToolKit

protocol AssetAccountRepositoryAPI: AnyObject {
    var accounts: Single<[AssetAccount]> { get }
}

/// A repository for `AssetAccount` objects
@available(*, deprecated, message: "Used only by ExchangeAccountRepository.")
final class AssetAccountRepository: AssetAccountRepositoryAPI {

    private let wallet: Wallet
    private let stellarWallet: StellarWalletAccountRepositoryAPI
    private let enabledCurrenciesService: EnabledCurrenciesServiceAPI
    private var cachedAccounts = Atomic<[AssetAccount]?>(nil)

    init(
        wallet: Wallet = WalletManager.shared.wallet,
        stellarWallet: StellarWalletAccountRepositoryAPI = resolve(),
        enabledCurrenciesService: EnabledCurrenciesServiceAPI = resolve()
    ) {
        self.wallet = wallet
        self.enabledCurrenciesService = enabledCurrenciesService
        self.stellarWallet = stellarWallet
    }

    // MARK: Public Properties

    var accounts: Single<[AssetAccount]> {
        guard let value = cachedAccounts.value else {
            return fetchAccounts()
        }
        return .just(value)
    }

    // MARK: Public Methods

    private func accounts(for assetType: CryptoCurrency) -> Single<[AssetAccount]> {
        Single.just([])
            .observeOn(MainScheduler.asyncInstance)
            .flatMap(weak: self) { (self, _) -> Single<[AssetAccount]> in
                guard self.wallet.isInitialized() else {
                    return .just([])
                }
                switch assetType {
                case .algorand, .polkadot:
                    return .just([])
                case .bitcoin,
                     .bitcoinCash:
                    return self.legacyAddress(assetType: assetType)
                case .erc20:
                    return self.erc20Account(cryptoCurrency: assetType)
                case .ethereum:
                    return self.ethereumAccount()
                case .stellar:
                    return self.stellarAccount()
                }
            }
    }

    private func fetchAccounts() -> Single<[AssetAccount]> {
        let streams: [Single<[AssetAccount]>] = enabledCurrenciesService.allEnabledCryptoCurrencies.map {
            accounts(for: $0)
        }
        return Single.zip(streams)
            .subscribeOn(MainScheduler.asyncInstance)
            .map { $0.flatMap { $0 } }
            .do(onSuccess: { [weak self] accounts in
                self?.cachedAccounts.mutate { $0 = accounts }
            })
    }

    // MARK: Private Methods

    private func stellarAccount() -> Single<[AssetAccount]> {
        guard let account = stellarWallet.defaultAccount else {
            return .just([])
        }
        let address = AssetAddressFactory.create(
            fromAddressString: account.publicKey,
            assetType: .stellar
        )
        return .just([AssetAccount(address: address)])
    }

    private func erc20Account(cryptoCurrency: CryptoCurrency) -> Single<[AssetAccount]> {
        guard let ethereumAddress = self.ethereumAddress() else {
            return .just([])
        }

        let address = AssetAddressFactory.create(
            fromAddressString: ethereumAddress,
            assetType: cryptoCurrency
        )
        return .just([AssetAccount(address: address)])
    }

    private func cachedAccount(assetType: CryptoCurrency) -> Single<[AssetAccount]> {
        accounts.map { result -> [AssetAccount] in
            result.filter { $0.address.cryptoCurrency == assetType }
        }
    }

    private func ethereumAddress() -> String? {
        guard wallet.hasEthAccount() else {
            Logger.shared.debug("This wallet has no Ethereum Account.")
            return nil
        }
        guard let ethereumAddress = self.wallet.getEtherAddress() else {
            Logger.shared.debug("This wallet has no Ethereum address.")
            return nil
        }
        return ethereumAddress
    }

    private func ethereumAccount() -> Single<[AssetAccount]> {
        guard let ethereumAddress = self.ethereumAddress() else {
            return .just([])
        }

        let address = AssetAddressFactory.create(
            fromAddressString: ethereumAddress,
            assetType: .ethereum
        )
        return .just([AssetAccount(address: address)])
    }

    private func legacyAddress(assetType: CryptoCurrency) -> Single<[AssetAccount]> {
        let activeAccountsCount: Int32 = wallet.getActiveAccountsCount(assetType.legacy)
        /// Must have at least one address
        guard activeAccountsCount > 0 else {
            return .just([])
        }
        let result: [AssetAccount] = Array(0..<activeAccountsCount)
            .map { wallet.getIndexOfActiveAccount($0, assetType: assetType.legacy) }
            .compactMap { AssetAccount.create(assetType: assetType, index: $0, wallet: wallet) }
        return .just(result)
    }
}

extension AssetAccount {

    /// Creates a new AssetAccount. This method only supports creating an AssetAccount for BTC or BCH.
    fileprivate static func create(assetType: CryptoCurrency, index: Int32, wallet: Wallet) -> AssetAccount? {
        guard let address = wallet.getReceiveAddress(forAccount: index, assetType: assetType.legacy) else {
            return nil
        }
        return AssetAccount(
            address: AssetAddressFactory.create(fromAddressString: address, assetType: assetType)
        )
    }
}
