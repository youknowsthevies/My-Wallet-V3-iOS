// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import Foundation
import NetworkKit

protocol PriceClientAPI {

    /// Aggregated call for multiple price quotes.
    /// - parameter base: Base fiat currency code. Must be supported in https://api.blockchain.info/price/symbols
    /// - parameter quote: Currencies to quote, fiat or crypto.
    /// - parameter time: The epoch seconds used to locate a time in the past.
    func price(
        bases: [String],
        quote: String,
        time: String?
    ) -> AnyPublisher<PriceResponse.IndexMulti.Response, NetworkError>

    /// Fetches the prices of the given `Currency` from the specified timestamp
    /// - parameter baseCurrencyCode: The currency code of which price will be fetched.
    /// - parameter quoteCurrencyCode: The currency code in which the price will be represented.
    /// - parameter start: The Unix Time timestamp of required moment.
    /// - parameter scale: The required time scale.
    /// - returns:A `Combine.Publisher` streaming an array of `PriceQuoteAtTimeResponse` on success, or a `NetworkError` on failure.
    func priceSeries(
        of baseCurrencyCode: String,
        in quoteCurrencyCode: String,
        start: String,
        scale: String
    ) -> AnyPublisher<[PriceResponse.Item], NetworkError>
}

/// Class for interacting with Blockchain's Service-Price backend service.
///
/// This service is in charge of all price related data (e.g. crypto to fiat prices, etc.)
///
/// API Spec https://api.blockchain.com/price/specs
final class PriceClient: PriceClientAPI {

    // MARK: - Private properties

    private let networkAdapter: NetworkAdapterAPI
    private let requestBuilder: RequestBuilder

    // MARK: - Init

    init(
        networkAdapter: NetworkAdapterAPI = resolve(),
        requestBuilder: RequestBuilder = resolve()
    ) {
        self.networkAdapter = networkAdapter
        self.requestBuilder = requestBuilder
    }

    func price(
        bases: [String],
        quote: String,
        time: String?
    ) -> AnyPublisher<PriceResponse.IndexMulti.Response, NetworkError> {
        let request: NetworkRequest! = PriceRequest.IndexMulti.request(
            requestBuilder: requestBuilder,
            bases: bases,
            quote: quote,
            time: time
        )
        return networkAdapter.perform(request: request)
    }

    func priceSeries(
        of baseCurrencyCode: String,
        in quoteCurrencyCode: String,
        start: String,
        scale: String
    ) -> AnyPublisher<[PriceResponse.Item], NetworkError> {
        let request: NetworkRequest! = PriceRequest.IndexSeries.request(
            requestBuilder: requestBuilder,
            base: baseCurrencyCode,
            quote: quoteCurrencyCode,
            start: start,
            scale: scale
        )
        return networkAdapter.perform(request: request)
    }
}
