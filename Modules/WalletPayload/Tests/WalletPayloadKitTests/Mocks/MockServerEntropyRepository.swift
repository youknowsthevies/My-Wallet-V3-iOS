// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import WalletPayloadKit

final class MockServerEntropyRepository: ServerEntropyRepositoryAPI {

    var serverEntropyResult: Result<String, ServerEntropyError>?

    func getServerEntropy(
        bytes: EntropyBytes,
        format: EntropyFormat
    ) -> AnyPublisher<String, ServerEntropyError> {
        guard let result = serverEntropyResult else {
            return .failure(.failureToRetrieve)
        }
        return result.publisher
            .eraseToAnyPublisher()
    }
}
