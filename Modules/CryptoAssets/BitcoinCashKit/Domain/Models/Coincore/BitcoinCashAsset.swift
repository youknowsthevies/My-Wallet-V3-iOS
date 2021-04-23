//
//  BitcoinCashAsset.swift
//  BitcoinCashKit
//
//  Created by Paulo on 11/08/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

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
                    id: account.publicKey,
                    derivationType: account.derivationType,
                    label: account.label,
                    isDefault: true,
                    hdAccountIndex: account.index
                )
            }
    }

    let kycTiersService: KYCTiersServiceAPI
    private let exchangeAccountProvider: ExchangeAccountsProviderAPI
    private let repository: BitcoinCashWalletAccountRepository
    private let errorRecorder: ErrorRecording
    private let addressValidator: BitcoinCashAddressValidatorAPI

    init(repository: BitcoinCashWalletAccountRepository = resolve(),
         errorRecorder: ErrorRecording = resolve(),
         exchangeAccountProvider: ExchangeAccountsProviderAPI = resolve(),
         addressValidator: BitcoinCashAddressValidatorAPI = resolve(),
         kycTiersService: KYCTiersServiceAPI = resolve()) {
        self.repository = repository
        self.errorRecorder = errorRecorder
        self.exchangeAccountProvider = exchangeAccountProvider
        self.addressValidator = addressValidator
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
        addressValidator.validate(address: address)
            .andThen(
                .just(
                    BitcoinChainReceiveAddress<BitcoinCashToken>(
                        address: address,
                        label: address,
                        onTxCompleted: { _ in Completable.empty() }
                    )
                )
            )
            .catchErrorJustReturn(nil)
    }

    // MARK: - Helpers

    private var allAccountsGroup: Single<AccountGroup> {
        let asset = self.asset
        return Single.zip(nonCustodialGroup,
                          custodialGroup,
                          interestGroup,
                          exchangeGroup)
            .map { (nonCustodialGroup, custodialGroup, interestGroup, exchangeGroup) -> [SingleAccount] in
                    nonCustodialGroup.accounts +
                    custodialGroup.accounts +
                    interestGroup.accounts +
                    exchangeGroup.accounts
            }
            .map { accounts -> AccountGroup in
                CryptoAccountNonCustodialGroup(asset: asset, accounts: accounts)
            }
    }

    private var custodialGroup: Single<AccountGroup> {
        .just(CryptoAccountCustodialGroup(asset: asset, accounts: [CryptoTradingAccount(asset: asset)]))
    }
    
    private var exchangeGroup: Single<AccountGroup> {
        let asset = self.asset
        return exchangeAccountProvider
            .account(for: asset)
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
        return repository.accounts
            .flatMap(weak: self) { (self, accounts) -> Single<(defaultAccount: BitcoinCashWalletAccount, accounts: [BitcoinCashWalletAccount])> in
                self.repository.defaultAccount
                    .map { ($0, accounts) }
            }
            .map { (defaultAccount, accounts) -> [SingleAccount] in
                accounts.map { account in
                    BitcoinCashCryptoAccount(
                        id: account.publicKey,
                        derivationType: account.derivationType,
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
