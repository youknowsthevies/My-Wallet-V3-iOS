// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import Foundation

public protocol AttributionRepositoryAPI {
    /// Repository used to retrieve conversion values from BE
    /// - Returns: A single integer representing the conversion value
    func fetchAttributionValues() -> AnyPublisher<Int, NetworkError>
}
