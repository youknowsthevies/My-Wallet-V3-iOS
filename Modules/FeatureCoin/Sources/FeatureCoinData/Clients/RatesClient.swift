// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation
import NetworkError
import NetworkKit

public protocol RatesClientAPI {

    func fetchInterestAccountRateForCurrencyCode(
        _ currencyCode: String
    ) -> AnyPublisher<InterestAccountRateResponse, NetworkError>
}

public struct RatesClient: RatesClientAPI {

    // MARK: - Private Properties

    private let networkAdapter: NetworkAdapterAPI
    private let requestBuilder: RequestBuilder

    // MARK: - Setup

    public init(
        networkAdapter: NetworkAdapterAPI,
        requestBuilder: RequestBuilder
    ) {
        self.networkAdapter = networkAdapter
        self.requestBuilder = requestBuilder
    }

    public func fetchInterestAccountRateForCurrencyCode(
        _ currencyCode: String
    ) -> AnyPublisher<InterestAccountRateResponse, NetworkError> {
        let parameters = [
            URLQueryItem(
                name: "ccy",
                value: currencyCode
            )
        ]
        let request = requestBuilder.get(
            path: "/savings/rates",
            parameters: parameters,
            authenticated: true
        )!

        return networkAdapter
            .perform(request: request)
    }
}
