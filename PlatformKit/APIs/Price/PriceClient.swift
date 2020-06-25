//
//  PriceClient.swift
//  PlatformKit
//
//  Created by AlexM on 9/24/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import NetworkKit
import RxSwift

public protocol PriceClientAPI {

    func priceSeries(of cryptoCurrency: CryptoCurrency, in fiatCurrency: FiatCurrency, start: String, scale: String) -> Single<[PriceInFiat]>

    /// Fetches the price of the given `CryptoCurrency` in the specific timestamp
    /// - parameter cryptoCurrency: The `CryptoCurrency` of which price will be fetched.
    /// - parameter fiatCurrency: The `FiatCurrency` in which the price will be represented.
    /// - parameter timestamp: The Unix Time timestamp of required moment. A nil value gets the current price.
    func price(for cryptoCurrency: CryptoCurrency, in fiatCurrency: FiatCurrency, at timestamp: UInt64?) -> Single<PriceInFiat>
}

/// Class for interacting with Blockchain's Service-Price backend service.
///
/// This service is in charge of all price related data (e.g. crypto to fiat prices, etc.)
///
/// API Spec https://api.blockchain.com/price/specs
final class PriceClient: PriceClientAPI {

    // MARK: - Types

    private enum Endpoint {
        static func priceSeries(base: String, quote: String, start: String, scale: String) -> (path: [String], query: [URLQueryItem]) {
            (
                path: ["price", "index-series"],
                query: [
                    URLQueryItem(name: "base", value: base),
                    URLQueryItem(name: "quote", value: quote),
                    URLQueryItem(name: "start", value: start),
                    URLQueryItem(name: "scale", value: scale)
                ]
            )
        }
        static func price(at timestamp: UInt64?,
                          fiatCurrency: FiatCurrency,
                          cryptoCurrency: CryptoCurrency) -> (path: [String], query: [URLQueryItem]) {
            var items = [
                URLQueryItem(name: "base", value: cryptoCurrency.code),
                URLQueryItem(name: "quote", value: fiatCurrency.code)
            ]
            if let timestamp = timestamp {
                items.append(URLQueryItem(name: "time", value: "\(timestamp)"))
            }
            return ( path: ["price", "index"], query: items )
        }
    }
    
    // MARK: - Private properties

    private let communicator: NetworkCommunicatorAPI
    private let requestBuilder: RequestBuilder

    // MARK: - Init

    init(communicator: NetworkCommunicatorAPI = Network.Dependencies.default.communicator,
         requestBuilder: RequestBuilder = RequestBuilder(networkConfig: Network.Dependencies.default.blockchainAPIConfig)) {
        self.communicator = communicator
        self.requestBuilder = requestBuilder
    }

    // MARK: - APIClientAPI

    func priceSeries(of cryptoCurrency: CryptoCurrency, in fiatCurrency: FiatCurrency, start: String, scale: String) -> Single<[PriceInFiat]> {
        let data = Endpoint.priceSeries(base: cryptoCurrency.code, quote: fiatCurrency.code, start: start, scale: scale)
        guard let request = requestBuilder.get(path: data.path, parameters: data.query) else {
            return .error(NetworkRequest.NetworkError.generic)
        }
        return communicator.perform(request: request)
    }

    func price(for cryptoCurrency: CryptoCurrency, in fiatCurrency: FiatCurrency, at timestamp: UInt64?) -> Single<PriceInFiat> {
        let data = Endpoint.price(at: timestamp, fiatCurrency: fiatCurrency, cryptoCurrency: cryptoCurrency)
        guard let request = requestBuilder.get(path: data.path, parameters: data.query) else {
            return .error(NetworkRequest.NetworkError.generic)
        }
        return communicator.perform(request: request)
    }
}
