// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import FeatureAuthenticationDomain
@testable import WalletPayloadKit

import Combine
import ToolKit

extension FeatureAuthenticationDomain.WalletRecoveryService {
    public static func mock() -> Self {
        Self(
            recoverFromMetadata: { _ -> AnyPublisher<Either<EmptyValue, WalletFetchedContext>, WalletError> in
                .just(.left(.noValue))
            }
        )
    }
}
