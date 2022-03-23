// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation
import WalletPayloadKit

final class MockWalletEncoder: WalletEncodingAPI {

    var transformValue: AnyPublisher<EncodedWalletPayload, WalletEncodingError> = .failure(
        .genericFailure
    )

    func transform(wrapper: Wrapper) -> AnyPublisher<EncodedWalletPayload, WalletEncodingError> {
        transformValue
    }

    var encodeValue: AnyPublisher<WalletCreationPayload, WalletEncodingError> = .failure(
        .genericFailure
    )

    func encode(
        payload: EncodedWalletPayload,
        applyChecksum: @escaping (Data) -> String
    ) -> AnyPublisher<WalletCreationPayload, WalletEncodingError> {
        encodeValue
    }
}
