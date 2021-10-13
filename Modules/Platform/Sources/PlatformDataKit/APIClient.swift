// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import NabuNetworkError
import NetworkKit
import PlatformKit
import ToolKit

typealias PlatformDataAPIClient = InterestAccountEligibilityClientAPI & PriceClientAPI

final class APIClient: PlatformDataAPIClient {

    private enum Path {
        static let interestEligibility = ["eligible", "product", "savings"]
    }

    private enum Parameter {
        static let currency = "currency"
        static let ccy = "ccy"
    }

    // MARK: - Private Properties

    private let requestBuilder: RequestBuilder
    private let networkAdapter: NetworkAdapterAPI

    private let priceRequestBuilder: RequestBuilder
    private let priceNetworkAdapter: NetworkAdapterAPI

    // MARK: - Setup

    init(
        networkAdapter: NetworkAdapterAPI = resolve(tag: DIKitContext.retail),
        priceNetworkAdapter: NetworkAdapterAPI = resolve(),
        requestBuilder: RequestBuilder = resolve(tag: DIKitContext.retail),
        priceRequestBuilder: RequestBuilder = resolve()
    ) {
        self.networkAdapter = networkAdapter
        self.requestBuilder = requestBuilder
        self.priceNetworkAdapter = priceNetworkAdapter
        self.priceRequestBuilder = priceRequestBuilder
    }

    // MARK: - InterestAccountEligibilityClientAPI

    func fetchInterestAccountEligibilityResponse()
        -> AnyPublisher<InterestEligibilityResponse, NabuNetworkError>
    {
        let request = requestBuilder.get(
            path: Path.interestEligibility,
            authenticated: true
        )!

        return networkAdapter
            .perform(request: request)
    }

    // MARK: - PriceClientAPI

    func symbols()
        -> AnyPublisher<PriceResponse.Symbols.Response, NetworkError>
    {
        let request: NetworkRequest! = PriceRequest.Symbols.request(
            requestBuilder: priceRequestBuilder
        )
        return priceNetworkAdapter.perform(request: request)
    }

    func price(
        of bases: Set<String>,
        in quote: String,
        time: String?
    ) -> AnyPublisher<PriceResponse.IndexMulti.Response, NetworkError> {
        let request: NetworkRequest! = PriceRequest.IndexMulti.request(
            requestBuilder: priceRequestBuilder,
            bases: bases,
            quote: quote,
            time: time
        )
        return priceNetworkAdapter.perform(request: request)
    }

    func priceSeries(
        of base: String,
        in quote: String,
        start: String,
        scale: String
    ) -> AnyPublisher<[PriceResponse.Item], NetworkError> {
        let request: NetworkRequest! = PriceRequest.IndexSeries.request(
            requestBuilder: priceRequestBuilder,
            base: base,
            quote: quote,
            start: start,
            scale: scale
        )
        return priceNetworkAdapter.perform(request: request)
    }
}
