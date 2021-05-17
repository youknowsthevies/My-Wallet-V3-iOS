// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import NetworkKit
import PlatformKit
import RxSwift

public protocol SavingsAccountClientAPI: AnyObject {
    func balance(with fiatCurrency: FiatCurrency) -> Single<SavingsAccountBalanceResponse?>
    func limits(fiatCurrency: FiatCurrency) -> Single<SavingsAccountLimitsResponse>
    func rate(for currency: String) -> Single<SavingsAccountInterestRateResponse>
}

final class SavingsAccountClient: SavingsAccountClientAPI {

    private enum Path {
        static let balance = [ "accounts", "savings" ]
        static let rate = [ "savings", "rates" ]
        static let limits = [ "savings", "limits" ]
    }

    private enum Parameter {
        static let currency = "currency"
        static let ccy = "ccy"
    }

    // MARK: - Private Properties

    private let requestBuilder: RequestBuilder
    private let networkAdapter: NetworkAdapterAPI

    // MARK: - Setup

    init(networkAdapter: NetworkAdapterAPI = resolve(tag: DIKitContext.retail),
         requestBuilder: RequestBuilder = resolve(tag: DIKitContext.retail)) {
        self.networkAdapter = networkAdapter
        self.requestBuilder = requestBuilder
    }

    // MARK: - SavingsAccountClientAPI

    func limits(fiatCurrency: FiatCurrency) -> Single<SavingsAccountLimitsResponse> {
        let parameters = [
            URLQueryItem(
                name: Parameter.currency,
                value: fiatCurrency.code
            )
        ]
        let request = requestBuilder.get(
            path: Path.limits,
            parameters: parameters,
            authenticated: true
        )!
        return networkAdapter
            .perform(
                request: request,
                errorResponseType: NabuNetworkError.self
            )
    }

    func balance(with fiatCurrency: FiatCurrency) -> Single<SavingsAccountBalanceResponse?> {
        let parameters = [
            URLQueryItem(
                name: Parameter.currency,
                value: fiatCurrency.code
            )
        ]
        let request = requestBuilder.get(
            path: Path.balance,
            parameters: parameters,
            authenticated: true
        )!
        return networkAdapter
            .performOptional(
                request: request,
                responseType: SavingsAccountBalanceResponse.self,
                errorResponseType: NabuNetworkError.self
            )
    }

    func rate(for currency: String) -> Single<SavingsAccountInterestRateResponse> {
        let parameters = [
            URLQueryItem(
                name: Parameter.ccy,
                value: currency
            )
        ]
        let request = requestBuilder.get(
            path: Path.rate,
            parameters: parameters,
            authenticated: true
        )!
        return networkAdapter
            .perform(
                request: request,
                errorResponseType: NabuNetworkError.self
            )
    }
}
