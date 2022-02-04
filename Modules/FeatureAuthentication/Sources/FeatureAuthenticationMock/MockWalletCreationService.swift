// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
@testable import FeatureAuthenticationDomain
import WalletPayloadKit

extension WalletCreationService {
    public static func mock() -> Self {
        WalletCreationService(
            createWallet: { _, _, _ -> AnyPublisher<WalletCreatedContext, WalletCreationServiceError> in
                .failure(WalletCreationServiceError.creationFailure(.genericFailure))
            },
            setResidentialInfo: { _, _ -> AnyPublisher<Void, Never> in
                .just(())
            }
        )
    }
}
