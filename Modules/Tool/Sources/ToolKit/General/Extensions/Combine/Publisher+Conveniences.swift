// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine

extension Publisher {
    /// - Parameters:
    ///   - transform: A mapping function that converts `Result<Output,Failure>` to another type.
    /// - Returns: A publiser of type <Result<Output, Failure>, Never>
    public func mapToResult() -> AnyPublisher<Result<Output, Failure>, Never> {
        map(Result.success)
            .catch { Just(.failure($0)) }
            .eraseToAnyPublisher()
    }
}
