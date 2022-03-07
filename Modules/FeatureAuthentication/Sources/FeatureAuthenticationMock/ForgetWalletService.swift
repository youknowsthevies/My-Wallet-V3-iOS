// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
@testable import FeatureAuthenticationDomain
import WalletPayloadKit

extension ForgetWalletService {
    public static func mock(called: @escaping () -> Void) -> Self {
        ForgetWalletService {
            called()
        }
    }
}
