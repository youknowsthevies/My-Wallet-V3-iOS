// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation
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
        applyChecksum: @escaping (Data) -> String
    ) -> AnyPublisher<WalletCreationPayload, WalletEncodingError> {
        encodeValue
    }
}
