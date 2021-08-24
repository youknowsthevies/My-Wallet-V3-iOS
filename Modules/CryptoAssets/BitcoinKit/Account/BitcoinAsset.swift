// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BitcoinChainKit
import DIKit
import PlatformKit
import RxSwift
import ToolKit

final class BitcoinAsset: CryptoAsset {

    let asset: CryptoCurrency = .coin(.bitcoin)

    var defaultAccount: Single<SingleAccount> {
        repository.defaultAccount
            .map { account in
                BitcoinCryptoAccount(
                    walletAccount: account,
                    isDefault: true
                )
            }
    }

    let kycTiersService: KYCTiersServiceAPI
    private let addressFactory: CryptoReceiveAddressFactory
    private let errorRecorder: ErrorRecording
    private let exchangeAccountProvider: ExchangeAccountsProviderAPI
    private let repository: BitcoinWalletAccountRepository

    init(
        addressFactory: CryptoReceiveAddressFactory = resolve(tag: CoinAssetModel.bitcoin.typeTag),
        errorRecorder: ErrorRecording = resolve(),
        exchangeAccountProvider: ExchangeAccountsProviderAPI = resolve(),
        kycTiersService: KYCTiersServiceAPI = resolve(),
        repository: BitcoinWalletAccountRepository = resolve()
    ) {
        self.addressFactory = addressFactory
        self.errorRecorder = errorRecorder
        self.exchangeAccountProvider = exchangeAccountProvider
        self.kycTiersService = kycTiersService
        self.repository = repository
    }

    func initialize() -> Completable {
        // Run wallet renaming procedure on initialization.
        nonCustodialGroup.map(\.accounts)
            .flatMapCompletable(weak: self) { (self, accounts) -> Completable in
                self.upgradeLegacyLabels(accounts: accounts)
            }
            .onErrorComplete()
    }

    func accountGroup(filter: AssetFilter) -> Single<AccountGroup> {
        switch filter {
        case .all:
            return allAccountsGroup
        case .custodial:
            return custodialGroup
        case .interest:
            return interestGroup
        case .nonCustodial:
            return nonCustodialGroup
        case .exchange:
            return exchangeGroup
        }
    }

    func parse(address: String) -> Single<ReceiveAddress?> {
        let externalAddress = try? addressFactory
            .makeExternalAssetAddress(
                asset: asset,
                address: address,
                label: address,
                onTxCompleted: { _ in Completable.empty() }
            )
            .get()
        return .just(externalAddress)
    }

    // MARK: - Helpers

    private var allAccountsGroup: Single<AccountGroup> {
        Single
            .zip([
                nonCustodialGroup,
                custodialGroup,
                interestGroup,
                exchangeGroup
            ])
            .flatMapAllAccountGroup()
    }

    private var custodialGroup: Single<AccountGroup> {
        .just(CryptoAccountCustodialGroup(asset: asset, account: CryptoTradingAccount(asset: asset)))
    }

    private var interestGroup: Single<AccountGroup> {
        guard asset.assetModel.products.contains(.interestBalance) else {
            return .just(CryptoAccountCustodialGroup(asset: asset))
        }
        return .just(CryptoAccountCustodialGroup(asset: asset, account: CryptoInterestAccount(asset: asset)))
    }

    private var exchangeGroup: Single<AccountGroup> {
        guard asset.assetModel.products.contains(.mercuryDeposits) else {
            return .just(CryptoAccountCustodialGroup(asset: asset))
        }
        return exchangeAccountProvider
            .account(for: asset)
            .map { [asset] account in
                CryptoAccountCustodialGroup(asset: asset, account: account)
            }
            .catchErrorJustReturn(CryptoAccountCustodialGroup(asset: asset))
    }

    private var nonCustodialGroup: Single<AccountGroup> {
        repository.activeAccounts
            .flatMap(weak: self) { (self, accounts) -> Single<(defaultAccount: BitcoinWalletAccount, accounts: [BitcoinWalletAccount])> in
                self.repository.defaultAccount
                    .map { ($0, accounts) }
            }
            .map { defaultAccount, accounts -> [SingleAccount] in
                accounts.map { account in
                    BitcoinCryptoAccount(
                        walletAccount: account,
                        isDefault: account.publicKeys.default == defaultAccount.publicKeys.default
                    )
                }
            }
            .map { [asset] accounts -> AccountGroup in
                CryptoAccountNonCustodialGroup(asset: asset, accounts: accounts)
            }
            .recordErrors(on: errorRecorder)
            .catchErrorJustReturn(CryptoAccountNonCustodialGroup(asset: asset, accounts: []))
    }
}
