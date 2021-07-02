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
        .just(CryptoAccountCustodialGroup(asset: asset, accounts: [CryptoTradingAccount(asset: asset)]))
    }

    private var exchangeGroup: Single<AccountGroup> {
        let asset = self.asset
        return exchangeAccountProvider
            .account(for: asset)
            .optional()
            .catchError { error in
                /// TODO: This shouldn't prevent users from seeing all accounts.
                /// Potentially return nil should this fail.
                guard let serviceError = error as? ExchangeAccountsNetworkError else {
                    #if INTERNAL_BUILD
                    Logger.shared.error(error)
                    throw error
                    #else
                    return Single.just(nil)
                    #endif
                }
                switch serviceError {
                case .missingAccount:
                    return Single.just(nil)
                }
            }
            .map { account in
                guard let account = account else {
                    return CryptoAccountCustodialGroup(asset: asset, accounts: [])
                }
                return CryptoAccountCustodialGroup(asset: asset, accounts: [account])
            }
    }

    private var interestGroup: Single<AccountGroup> {
        let asset = self.asset
        return Single
            .just(CryptoInterestAccount(asset: asset))
            .map { CryptoAccountCustodialGroup(asset: asset, accounts: [$0]) }
    }

    private var nonCustodialGroup: Single<AccountGroup> {
        let asset = self.asset
        return repository.activeAccounts
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
            .map { accounts -> AccountGroup in
                CryptoAccountNonCustodialGroup(asset: asset, accounts: accounts)
            }
            .recordErrors(on: errorRecorder)
            .catchErrorJustReturn(CryptoAccountNonCustodialGroup(asset: asset, accounts: []))
    }
}
