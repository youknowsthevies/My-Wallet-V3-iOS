// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import FeatureAuthenticationDomain

final class MockUserAlreadyRestoredHandler: UserAlreadyRestoredHandlerAPI {

    var recordedWalletIdHint: String = ""

    func send(
        walletIdHint: String
    ) -> AnyPublisher<Void, NabuAuthenticationExecutorError> {
        recordedWalletIdHint = walletIdHint
        return .just(())
    }
}
