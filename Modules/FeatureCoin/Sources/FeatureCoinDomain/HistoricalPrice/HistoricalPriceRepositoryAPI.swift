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
