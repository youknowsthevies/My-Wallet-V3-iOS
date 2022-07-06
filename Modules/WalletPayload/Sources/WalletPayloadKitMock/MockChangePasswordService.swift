// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import WalletPayloadDataKit
@testable import WalletPayloadKit

import Combine
import Errors

final class MockChangePasswordService: ChangePasswordServiceAPI {

    var changePasswordCalled: Bool = false
    var changePasswordResult: Result<Void, ChangePasswordError> = .failure(.syncFailed)
    func change(password: String) -> AnyPublisher<Void, ChangePasswordError> {
        changePasswordCalled = true
        return changePasswordResult.publisher
            .eraseToAnyPublisher()
    }
}
