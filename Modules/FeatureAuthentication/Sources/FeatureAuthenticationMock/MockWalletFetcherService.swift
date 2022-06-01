// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
@testable import FeatureAuthenticationDomain
import ToolKit
import WalletPayloadKit

public final class WalletFetcherServiceMock {
    public var fetchWalletCalled: Bool = false
    public var fetchWalletAfterAccountRecoveryCalled: Bool = false

    public init() {}

    public func mock() -> WalletFetcherService {
        WalletFetcherService(
            fetchWallet: { [weak self] _, _, _ -> AnyPublisher<EmptyValue, WalletError> in
                self?.fetchWalletCalled = true
                return .just(.noValue)
            },
            fetchWalletAfterAccountRecovery: { [weak self] _, _, _, _ -> AnyPublisher<EmptyValue, WalletError> in
                self?.fetchWalletAfterAccountRecoveryCalled = true
                return .just(.noValue)
            }
        )
    }
}
