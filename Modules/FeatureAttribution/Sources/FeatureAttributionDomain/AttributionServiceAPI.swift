// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import Foundation

public protocol AttributionServiceAPI {
    func startUpdatingConversionValues() -> AnyPublisher<Void, NetworkError>
    func registerForAttribution()
}
