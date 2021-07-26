// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformKit
import RxSwift
import stellarsdk
import ToolKit

final class StellarAsset: CryptoAsset {

    let asset: CryptoCurrency = .coin(.stellar)

    var defaultAccount: Single<SingleAccount> {
        Single.just(())
            .observeOn(MainScheduler.asyncInstance)
            .flatMap(weak: self) { (self, _) -> Maybe<StellarWalletAccount> in
                self.accountRepository.initializeMetadataMaybe()
            }
            .asObservable()
            .first()
            .map { account -> StellarWalletAccount in
                guard let account = account else {
                    throw StellarAccountError.noDefaultAccount
                }
                return account
            }
            .map { account -> SingleAccount in
                StellarCryptoAccount(publicKey: account.publicKey, label: account.label, hdAccountIndex: account.index)
            }
    }

    let kycTiersService: KYCTiersServiceAPI
    private let exchangeAccountProvider: ExchangeAccountsProviderAPI
    private let accountRepository: StellarWalletAccountRepositoryAPI
    private let errorRecorder: ErrorRecording
    private let addressFactory: StellarCryptoReceiveAddressFactory

    init(
        accountRepository: StellarWalletAccountRepositoryAPI = resolve(),
        errorRecorder: ErrorRecording = resolve(),
        exchangeAccountProvider: ExchangeAccountsProviderAPI = resolve(),
        kycTiersService: KYCTiersServiceAPI = resolve(),
        addressFactory: StellarCryptoReceiveAddressFactory = .init()
    ) {
        self.exchangeAccountProvider = exchangeAccountProvider
        self.accountRepository = accountRepository
        self.errorRecorder = errorRecorder
        self.kycTiersService = kycTiersService
        self.addressFactory = addressFactory
    }

    func initialize() -> Completable {
        // Run wallet renaming procedure on initialization.
        nonCustodialGroup.map(\.accounts)
            .flatMapCompletable(weak: self) { (self, accounts) -> Completable in
                self.upgradeLegacyLabels(accounts: accounts)
            }
            .onErrorComplete()
    }

    func parse(address: String) -> Single<ReceiveAddress?> {
        let result = try? addressFactory
            .makeExternalAssetAddress(
                asset: .coin(.stellar),
                address: address,
                label: address,
                onTxCompleted: { _ in Completable.empty() }
            )
            .get()
        return .just(result)
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
        .just(CryptoAccountCustodialGroup(asset: asset, account: CryptoInterestAccount(asset: asset)))
    }

    private var exchangeGroup: Single<AccountGroup> {
        exchangeAccountProvider
            .account(for: asset)
            .map { [asset] account in
                CryptoAccountCustodialGroup(asset: asset, account: account)
            }
            .catchErrorJustReturn(CryptoAccountCustodialGroup(asset: asset))
    }

    private var nonCustodialGroup: Single<AccountGroup> {
        let asset = self.asset
        return defaultAccount
            .map { account -> AccountGroup in
                CryptoAccountNonCustodialGroup(asset: asset, accounts: [account])
            }
            .recordErrors(on: errorRecorder)
            .catchErrorJustReturn(CryptoAccountNonCustodialGroup(asset: asset, accounts: []))
    }
}
