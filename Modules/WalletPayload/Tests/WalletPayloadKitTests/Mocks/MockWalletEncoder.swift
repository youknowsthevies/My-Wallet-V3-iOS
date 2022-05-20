// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation
import WalletPayloadKit

final class MockWalletEncoder: WalletEncodingAPI {

    var transformValue: AnyPublisher<EncodedWalletPayload, WalletEncodingError> = .failure(
        .genericFailure
    )

    var transformWrapperCalled: Bool = false
    func transform(wrapper: Wrapper) -> AnyPublisher<EncodedWalletPayload, WalletEncodingError> {
        transformWrapperCalled = true
        return transformValue
    }

    var encodeValue: AnyPublisher<WalletCreationPayload, WalletEncodingError> = .failure(
        .genericFailure
    )

    var encodePayloadCalled: Bool = false
    func encode(
        payload: EncodedWalletPayload,
        applyChecksum: @escaping (Data) -> String
    ) -> AnyPublisher<WalletCreationPayload, WalletEncodingError> {
        encodePayloadCalled = true
        return encodeValue
    }
}
