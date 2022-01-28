// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import WalletPayloadKit

final class MockWalletEncoder: WalletEncodingAPI {

    var trasformValue: AnyPublisher<EncodedWalletPayload, WalletEncodingError> = .failure(
        .genericFailure
    )

    func trasform(wrapper: Wrapper) -> AnyPublisher<EncodedWalletPayload, WalletEncodingError> {
        trasformValue
    }

    var encodeValue: AnyPublisher<WalletCreationPayload, WalletEncodingError> = .failure(
        .genericFailure
    )

    func encode(
        payload: EncodedWalletPayload,
        checksum: String,
        length: Int
    ) -> AnyPublisher<WalletCreationPayload, WalletEncodingError> {
        encodeValue
    }
}
