// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import WalletPayloadKit

import Combine
import ToolKit
import WalletPayloadDataKit

final class WalletSyncMock: WalletSyncAPI {
    var syncCalled: Bool = false
    var syncResult: Result<EmptyValue, WalletSyncError> = .failure(.unknown)
    func sync(
        wrapper: Wrapper,
        password: String
    ) -> AnyPublisher<EmptyValue, WalletSyncError> {
        syncCalled = true
        return syncResult.publisher.eraseToAnyPublisher()
    }
}
