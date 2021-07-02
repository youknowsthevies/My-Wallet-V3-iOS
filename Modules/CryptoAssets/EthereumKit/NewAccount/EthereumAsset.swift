// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformKit
import RxSwift
import ToolKit

final class EthereumAsset: CryptoAsset {

    let asset: CryptoCurrency = .ethereum

    var defaultAccount: Single<SingleAccount> {
        repository
            .defaultAccount
            .map { account -> SingleAccount in
                EthereumCryptoAccount(
                    publicKey: account.publicKey,
                    label: account.label,
                    hdAccountIndex: account.index
                )
            }
    }

    let kycTiersService: KYCTiersServiceAPI
    private let addressFactory: EthereumExternalAssetAddressFactory
    private let exchangeAccountProvider: ExchangeAccountsProviderAPI
    private let repository: EthereumWalletAccountRepositoryAPI
    private let errorRecorder: ErrorRecording

    init(repository: EthereumWalletAccountRepositoryAPI = resolve(),
         addressFactory: EthereumExternalAssetAddressFactory = .init(),
         errorRecorder: ErrorRecording = resolve(),
         exchangeAccountProvider: ExchangeAccountsProviderAPI = resolve(),
         kycTiersService: KYCTiersServiceAPI = resolve()) {
        self.addressFactory = addressFactory
        self.exchangeAccountProvider = exchangeAccountProvider
        self.repository = repository
        self.errorRecorder = errorRecorder
        self.kycTiersService = kycTiersService
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
        let receiveAddress = try? addressFactory
            .makeExternalAssetAddress(
                asset: asset,
                address: address,
                label: address,
                onTxCompleted: { _ in .empty() }
            )
            .get()
        return .just(receiveAddress)
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
        return defaultAccount
            .map { account -> AccountGroup in
                CryptoAccountNonCustodialGroup(asset: asset, accounts: [ account ])
            }
            .recordErrors(on: errorRecorder)
            .catchErrorJustReturn(CryptoAccountNonCustodialGroup(asset: asset, accounts: []))
    }
}
