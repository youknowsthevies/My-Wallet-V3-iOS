// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation
import MoneyKit
import NetworkError

public protocol HistoricalPriceRepositoryAPI {

    func fetchGraphData(
        base: CryptoCurrency,
        quote: FiatCurrency,
        series: Series,
        relativeTo: Date
    ) -> AnyPublisher<GraphData, NetworkError>
}

// MARK: - Preview Helper

struct PreviewHistoricalPriceRepository: HistoricalPriceRepositoryAPI {

    private let graphData: AnyPublisher<GraphData, NetworkError>

    init(_ graphData: AnyPublisher<GraphData, NetworkError> = .empty()) {
        self.graphData = graphData
    }

    func fetchGraphData(
        base: CryptoCurrency,
        quote: FiatCurrency,
        series: Series,
        relativeTo: Date
    ) -> AnyPublisher<GraphData, NetworkError> {
        graphData
    }
}
