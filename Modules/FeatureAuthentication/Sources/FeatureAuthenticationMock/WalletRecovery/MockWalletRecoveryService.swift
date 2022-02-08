// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
@testable import FeatureAuthenticationDomain
import WalletPayloadKit

extension WalletRecoveryService {
    public static func mock() -> Self {
        Self(
            recoverFromMetadata: { _ in
                .just(.noValue)
            },
            recover: { _, _, _ in
                .just(.noValue)
            }
        )
    }
}
