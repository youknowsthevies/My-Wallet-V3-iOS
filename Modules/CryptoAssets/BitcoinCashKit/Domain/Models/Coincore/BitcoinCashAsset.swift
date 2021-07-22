// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BitcoinChainKit
import DIKit
import PlatformKit
import RxSwift
import ToolKit

class BitcoinCashAsset: CryptoAsset {

    let asset: CryptoCurrency = .bitcoinCash

    var defaultAccount: Single<SingleAccount> {
        repository.defaultAccount
            .map { account in
                BitcoinCashCryptoAccount(
                    xPub: account.publicKey,
                    label: account.label,
                    isDefault: true,
                    hdAccountIndex: account.index
                )
            }
    }

    let kycTiersService: KYCTiersServiceAPI
    private let addressFactory: CryptoReceiveAddressFactory
    private let errorRecorder: ErrorRecording
    private let exchangeAccountProvider: ExchangeAccountsProviderAPI
    private let repository: BitcoinCashWalletAccountRepository

    init(
        addressFactory: CryptoReceiveAddressFactory = resolve(tag: CryptoCurrency.bitcoinCash),
        errorRecorder: ErrorRecording = resolve(),
        exchangeAccountProvider: ExchangeAccountsProviderAPI = resolve(),
        kycTiersService: KYCTiersServiceAPI = resolve(),
        repository: BitcoinCashWalletAccountRepository = resolve()
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

    private var exchangeGroup: Single<AccountGroup> {
        exchangeAccountProvider
            .account(for: asset)
            .map { [asset] account in
                CryptoAccountCustodialGroup(asset: asset, account: account)
            }
            .catchErrorJustReturn(CryptoAccountCustodialGroup(asset: asset))
    }

    private var interestGroup: Single<AccountGroup> {
        .just(CryptoAccountCustodialGroup(asset: asset, account: CryptoInterestAccount(asset: asset)))
    }

    private var nonCustodialGroup: Single<AccountGroup> {
        repository.activeAccounts
            .flatMap(weak: self) { (self, accounts) -> Single<(defaultAccount: BitcoinCashWalletAccount, accounts: [BitcoinCashWalletAccount])> in
                self.repository.defaultAccount
                    .map { ($0, accounts) }
            }
            .map { (defaultAccount, accounts) -> [SingleAccount] in
                accounts.map { account in
                    BitcoinCashCryptoAccount(
                        xPub: account.publicKey,
                        label: account.label,
                        isDefault: account.publicKey == defaultAccount.publicKey,
                        hdAccountIndex: account.index
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
