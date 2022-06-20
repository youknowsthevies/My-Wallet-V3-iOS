// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation
import NetworkError

public protocol AttributionServiceAPI {
    func startUpdatingConversionValues() -> AnyPublisher<Void, NetworkError>
    func registerForAttribution()
}
