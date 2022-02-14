// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
@testable import FeatureAuthenticationDomain
import ToolKit
import WalletPayloadKit

extension WalletFetcherService {
    public static var mock: Self {
        Self(
            fetchWallet: { _, _, _ -> AnyPublisher<EmptyValue, WalletError> in
                .just(.noValue)
            }
        )
    }
}
