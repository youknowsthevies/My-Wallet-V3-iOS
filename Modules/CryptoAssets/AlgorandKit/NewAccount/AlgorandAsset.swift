// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformKit
import RxSwift
import ToolKit

final class AlgorandAsset: CryptoAsset {

    let asset: CryptoCurrency = .algorand

    var defaultAccount: Single<SingleAccount> {
        .error(CryptoAssetError.noDefaultAccount)
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

    // MARK: - Private Properties

    let kycTiersService: KYCTiersServiceAPI
    private let exchangeAccountProvider: ExchangeAccountsProviderAPI

    // MARK: - Init

    init(exchangeAccountProvider: ExchangeAccountsProviderAPI = resolve(),
         kycTiersService: KYCTiersServiceAPI = resolve()) {
        self.exchangeAccountProvider = exchangeAccountProvider
        self.kycTiersService = kycTiersService
   }

    func parse(address: String) -> Single<ReceiveAddress?> {
        unimplemented()
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

    private var interestGroup: Single<AccountGroup> {
        .just(CryptoAccountCustodialGroup(asset: asset, accounts: []))
    }

    private var exchangeGroup: Single<AccountGroup> {
        exchangeAccountProvider
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
            .map { [asset] account in
                guard let account = account else {
                    return CryptoAccountCustodialGroup(asset: asset, accounts: [])
                }
                return CryptoAccountCustodialGroup(asset: asset, accounts: [account])
            }
    }

    private var nonCustodialGroup: Single<AccountGroup> {
        .just(CryptoAccountNonCustodialGroup(asset: asset, accounts: []))
    }
}
