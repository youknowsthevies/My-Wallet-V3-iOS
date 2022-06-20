// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import FeatureAttributionDomain
import Foundation
import NetworkError

public class AttributionRepository: AttributionRepositoryAPI {
    private let client: AttributionClientAPI

    public init(with client: AttributionClientAPI) {
        self.client = client
    }

    public func fetchAttributionValues() -> AnyPublisher<Int, NetworkError> {
        client.fetchWebsocketEvents()
            .compactMap { event in
                guard case .conversionValueUpdated(let response) = event else {
                    return nil
                }
                return response.conversionValue
            }
            .eraseToAnyPublisher()
    }
}
