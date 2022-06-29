// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import WalletPayloadKit

import Combine
import ToolKit
import WalletPayloadDataKit

final class WalletSyncMock: WalletSyncAPI {
    var syncCalled: Bool = false
    var syncResult: Result<EmptyValue, WalletSyncError> = .failure(.unknown)

    var givenWrapper: Wrapper?
    var givenPassword: String?

    func sync(
        wrapper: Wrapper,
        password: String
    ) -> AnyPublisher<EmptyValue, WalletSyncError> {
        syncCalled = true
        givenWrapper = wrapper
        givenPassword = password
        return syncResult.publisher.eraseToAnyPublisher()
    }
}
