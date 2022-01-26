// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine

public protocol WalletPayloadRepositoryAPI {

    func payload(
        guid: String,
        identifier: WalletPayloadIdentifier
    ) -> AnyPublisher<WalletPayload, WalletPayloadServiceError>
}
