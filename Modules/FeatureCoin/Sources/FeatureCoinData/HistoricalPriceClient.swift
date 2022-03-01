// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import FeatureCoinDomain
import Foundation
import NetworkKit

public struct HistoricalPriceClient: HistoricalPriceClientAPI {

    public let price: HistoricalPrice

    public let request: RequestBuilder
    public let network: NetworkAdapterAPI
    public let calendar: Calendar

    private let maxAge: TimeInterval = 1238992000

    public init(
        _ price: HistoricalPrice,
        request: RequestBuilder,
        network: NetworkAdapterAPI,
        calendar: Calendar = .current
    ) {
        self.price = price
        self.request = request
        self.network = network
        self.calendar = calendar
    }

    public func fetch(
        series: HistoricalPrice.Series,
        relativeTo date: Date
    ) -> AnyPublisher<GraphData, NetworkError> {
        indexes(for: series, relativeTo: date)
            .flatMap { data -> AnyPublisher<[GraphData.Index], NetworkError> in
                indexes(for: ._15_minutes, relativeTo: date)
                    .map { today in data + today }
                    .eraseToAnyPublisher()
            }
            .map { [price] series in
                GraphData(
                    series: series,
                    base: price.base,
                    quote: price.quote
                )
            }
            .eraseToAnyPublisher()
    }

    private func indexes(
        for series: HistoricalPrice.Series,
        relativeTo date: Date
    ) -> AnyPublisher<[GraphData.Index], NetworkError> {

        let startingAt = calendar.date(
            byAdding: series.window.component,
            value: -series.window.value,
            to: date
        )!

        let every = calendar.date(
            byAdding: series.scale.component,
            value: series.scale.value,
            to: date
        )!
            .timeIntervalSince(date)

        let start = startingAt.timeIntervalSince1970
            .clamped(to: maxAge...)

        let request = request.get(
            path: "/price/index-series",
            parameters: [
                URLQueryItem(name: "base", value: price.base.code),
                URLQueryItem(name: "quote", value: price.quote.code),
                URLQueryItem(name: "start", value: Int(start - every).description),
                URLQueryItem(name: "end", value: Int(date.timeIntervalSince1970).description),
                URLQueryItem(name: "scale", value: Int(every).description)
            ]
        )!

        return network.perform(request: request, responseType: [GraphData.Index].self)
    }
}
