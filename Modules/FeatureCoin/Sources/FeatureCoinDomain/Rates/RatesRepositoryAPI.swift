// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors

public protocol RatesRepositoryAPI {

    func fetchRate(
        code: String
    ) -> AnyPublisher<Double, NetworkError>
}

// MARK: - Preview Helper

public struct PreviewRatesRepository: RatesRepositoryAPI {

    private let rate: AnyPublisher<Double, NetworkError>

    public init(_ rate: AnyPublisher<Double, NetworkError> = .empty()) {
        self.rate = rate
    }

    public func fetchRate(
        code: String
    ) -> AnyPublisher<Double, NetworkError> {
        rate
    }
}
