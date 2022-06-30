// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import FeatureAuthenticationDomain
@testable import WalletPayloadKit

import Combine
import ToolKit

public final class WalletFetcherServiceMock {
    public var fetchWalletCalled: Bool = false
    public var fetchWalletAfterAccountRecoveryCalled: Bool = false

    public init() {}

    public func mock() -> WalletFetcherService {
        WalletFetcherService(
            fetchWallet: { [weak self] guid, sharedKey, password
                -> AnyPublisher<Either<EmptyValue, WalletFetchedContext>, WalletFetcherServiceError> in
                self?.fetchWalletCalled = true
                return .just(
                    .right(
                        WalletFetchedContext(
                            guid: guid,
                            sharedKey: sharedKey,
                            passwordPartHash: hashPassword(password)
                        )
                    )
                )
            },
            fetchWalletAfterAccountRecovery: { [weak self] guid, sharedKey, password, _
                -> AnyPublisher<Either<EmptyValue, WalletFetchedContext>, WalletFetcherServiceError> in
                self?.fetchWalletAfterAccountRecoveryCalled = true
                return .just(
                    .right(
                        WalletFetchedContext(
                            guid: guid,
                            sharedKey: sharedKey,
                            passwordPartHash: hashPassword(password)
                        )
                    )
                )
            }
        )
    }
}
