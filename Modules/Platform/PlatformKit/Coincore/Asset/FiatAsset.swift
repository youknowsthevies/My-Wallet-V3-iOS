// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import RxSwift
import ToolKit

class FiatAsset: Asset {

    // MARK: - Private Properties

    private let enabledCurrenciesService: EnabledCurrenciesServiceAPI

    // MARK: - Setup

    init(enabledCurrenciesService: EnabledCurrenciesServiceAPI = resolve()) {
        self.enabledCurrenciesService = enabledCurrenciesService
    }

    // MARK: - Asset

    func initialize() -> Completable {
        .empty()
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
        .just(nil)
    }

    // MARK: - Helpers

    private var allAccountsGroup: Single<AccountGroup> {
        custodialGroup
    }

    private var custodialGroup: Single<AccountGroup> {
        let accounts = enabledCurrenciesService.allEnabledFiatCurrencies
            .map { FiatCustodialAccount(fiatCurrency: $0) }
        return .just(FiatAccountGroup(accounts: accounts))
    }

    private var interestGroup: Single<AccountGroup> {
        unimplemented()
    }

    private var nonCustodialGroup: Single<AccountGroup> {
        unimplemented()
    }

    /// We cannot transfer for fiat
    func transactionTargets(account: SingleAccount) -> Single<[SingleAccount]> {
        .just([])
    }

}
