import Combine
import CoreGraphics
import Foundation
import MoneyKit
import NetworkError

public protocol HistoricalPriceClientAPI {

    func fetch(
        series: HistoricalPrice.Series,
        relativeTo date: Date
    ) -> AnyPublisher<GraphData, NetworkError>
}

extension HistoricalPriceClientAPI {

    public func fetch(
        series: HistoricalPrice.Series
    ) -> AnyPublisher<GraphData, NetworkError> {
        fetch(series: series, relativeTo: Date())
    }
}

extension HistoricalPriceService {

    public static var preview: HistoricalPriceService {
        .init(PreviewSinWaveHistoricalPriceClient())
    }
}

public struct HistoricalPriceService {

    let client: HistoricalPriceClientAPI

    public init(_ client: HistoricalPriceClientAPI) {
        self.client = client
    }

    public func fetch(
        series: HistoricalPrice.Series,
        relativeTo date: Date = Date()
    ) -> AnyPublisher<GraphData, NetworkError> {
        client.fetch(series: series, relativeTo: date)
            .eraseToAnyPublisher()
    }
}

private struct PreviewSinWaveHistoricalPriceClient: HistoricalPriceClientAPI {

    func fetch(
        series: HistoricalPrice.Series,
        relativeTo date: Date
    ) -> AnyPublisher<GraphData, NetworkError> {
        Just(
            GraphData(
                series: stride(
                    from: Double.pi,
                    to: series.cycles * Double.pi,
                    by: Double.pi / Double(180)
                )
                .map { sin($0) + 1 }
                .enumerated()
                .map {
                    .init(
                        price: $1 * 10,
                        timestamp: Date(timeIntervalSinceNow: Double($0) * 60 * series.cycles)
                    )
                },
                base: .bitcoin,
                quote: .USD
            )
        )
        .setFailureType(to: NetworkError.self)
        .eraseToAnyPublisher()
    }
}

extension HistoricalPrice.Series {

    fileprivate var cycles: Double {
        switch self {
        case .day:
            return 2
        case .week:
            return 3
        case .month:
            return 4
        case .year:
            return 5
        case .all:
            return 6
        default:
            return 1
        }
    }
}
