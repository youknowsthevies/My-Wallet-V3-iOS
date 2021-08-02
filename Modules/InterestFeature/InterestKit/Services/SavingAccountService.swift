// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformKit
import RxSwift
import ToolKit

public protocol SavingAccountServiceAPI: AnyObject, SavingsOverviewAPI {
    func balances(fetch: Bool) -> Single<CustodialAccountBalanceStates>
    func details(for currency: CryptoCurrency) -> Single<ValueCalculationState<SavingsAccountBalanceDetails>>
    func limits(for currency: CryptoCurrency) -> Single<SavingsAccountLimits?>
}

final class SavingAccountService: SavingAccountServiceAPI {

    // MARK: - Private Properties

    private let client: SavingsAccountClientAPI
    private let fiatCurrencyService: FiatCurrencyServiceAPI
    private let kycTiersService: KYCTiersServiceAPI
    private let cachedValue: CachedValue<SavingsAccountBalanceResponse>

    // MARK: - Setup

    init(
        client: SavingsAccountClientAPI = resolve(),
        fiatCurrencyService: FiatCurrencyServiceAPI = resolve(),
        kycTiersService: KYCTiersServiceAPI = resolve()
    ) {
        self.client = client
        self.fiatCurrencyService = fiatCurrencyService
        self.kycTiersService = kycTiersService
        cachedValue = CachedValue(configuration: .periodic(60))
        cachedValue.setFetch(weak: self) { (self) in
            self.fetchBalancesResponse()
        }
    }

    // MARK: - SavingAccountServiceAPI

    func limits(for currency: CryptoCurrency) -> Single<SavingsAccountLimits?> {
        fiatCurrencyService
            .fiatCurrency
            .flatMap(weak: self) { (self, fiatCurrency) in
                self.client.limits(fiatCurrency: fiatCurrency)
            }
            .map { $0[currency] }
    }

    func details(for currency: CryptoCurrency) -> Single<ValueCalculationState<SavingsAccountBalanceDetails>> {
        cachedValue.valueSingle
            .map { response -> ValueCalculationState<SavingsAccountBalanceDetails> in
                switch response[currency] {
                case .none:
                    return .invalid(.empty)
                case .some(let details):
                    return .value(details)
                }
            }
    }

    func balances(fetch: Bool) -> Single<CustodialAccountBalanceStates> {
        (fetch ? cachedValue.fetchValue : cachedValue.valueSingle)
            .map { CustodialAccountBalanceStates(response: $0) }
    }

    // MARK: - SavingsOverviewAPI

    func balance(for currency: CryptoCurrency) -> Single<CustodialAccountBalanceState> {
        balances(fetch: false)
            .map { $0[currency.currency] }
    }

    func rate(for currency: CryptoCurrency) -> Single<Double> {
        client.rate(for: currency.code)
            .map(\.rate)
    }

    private func fetchBalancesResponse() -> Single<SavingsAccountBalanceResponse> {
        Single
            .zip(
                kycTiersService.tiers.map(\.isTier2Approved),
                fiatCurrencyService.fiatCurrency
            )
            .flatMap(weak: self) { (self, values) -> Single<SavingsAccountBalanceResponse?> in
                let (tier2Approved, fiatCurrency) = values
                guard tier2Approved else {
                    return .just(nil)
                }
                return self.client.balance(with: fiatCurrency)
            }
            .catchErrorJustReturn(nil)
            .onNilJustReturn(SavingsAccountBalanceResponse.empty)
    }
}
