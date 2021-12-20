// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
@testable import FeatureAuthenticationDomain

final class MockResetPasswordService: ResetPasswordServiceAPI {

    func setNewPassword(newPassword: String) -> AnyPublisher<Void, ResetPasswordServiceError> {
        .just(())
    }
}
