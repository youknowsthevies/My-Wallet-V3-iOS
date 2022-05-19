// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import FeatureCoinDomain
import Foundation
import NetworkError

public struct AssetInformationRepository: AssetInformationRepositoryAPI {

    let client: AssetInformationClientAPI

    public init(_ client: AssetInformationClientAPI) {
        self.client = client
    }

    public func fetchInfo(_ currencyCode: String) -> AnyPublisher<AssetInformation, NetworkError> {
        client.fetchInfo(currencyCode)
            .map {
                AssetInformation(
                    description: $0.description,
                    whitepaper: $0.whitepaper,
                    website: $0.website
                )
            }
            .eraseToAnyPublisher()
    }
}
