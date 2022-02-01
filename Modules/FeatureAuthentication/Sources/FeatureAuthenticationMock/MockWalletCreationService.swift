// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
@testable import FeatureAuthenticationDomain
import WalletPayloadKit

extension WalletCreationService {
    public static func mock() -> Self {
        WalletCreationService(
            createWallet: { _, _, _, _ -> AnyPublisher<WalletCreation, WalletCreateError> in
                .failure(WalletCreateError.genericFailure)
            }
        )
    }
}
