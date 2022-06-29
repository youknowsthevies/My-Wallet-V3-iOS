// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BitcoinChainKit
import Combine
import Errors

protocol BchDustRepositoryAPI {
    func dust() -> AnyPublisher<DustMixing, NetworkError>
}

final class BchDustRepository: BchDustRepositoryAPI {

    private let client: APIClientAPI

    init(client: APIClientAPI) {
        self.client = client
    }

    func dust() -> AnyPublisher<DustMixing, NetworkError> {
        client.dust()
            .map(DustMixing.init(response:))
            .eraseToAnyPublisher()
    }
}
