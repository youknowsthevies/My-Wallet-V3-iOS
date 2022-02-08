// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation
import WalletPayloadKit

final class ServerEntropyRepository: ServerEntropyRepositoryAPI {

    private let client: ServerEntropyClientAPI

    init(client: ServerEntropyClientAPI) {
        self.client = client
    }

    func getServerEntropy(
        bytes: EntropyBytes,
        format: EntropyFormat
    ) -> AnyPublisher<String, ServerEntropyError> {
        client.getEntropy(
            request: EntropyRequest(
                bytes: bytes.value,
                format: format
            )
        )
        .mapError { _ in ServerEntropyError.failureToRetrieve }
        .eraseToAnyPublisher()
    }
}
