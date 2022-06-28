// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import ToolKit
import WalletPayloadKit

/// Provides state for current loaded wallet
public struct WalletStateProvider {

    /// A `AnyPublisher<Bool, Never>` that returns `true` when wallet is fully loaded, otherwise `false`
    public var isWalletInitializedPublisher: () -> AnyPublisher<Bool, Never>

    /// Releases the in-memory wallet state
    public var releaseState: () -> Void
}

extension WalletStateProvider {
    public static func live(
        holder: WalletHolderAPI
    ) -> Self {
        WalletStateProvider(
            isWalletInitializedPublisher: { [holder] () -> AnyPublisher<Bool, Never> in
                holder.walletStatePublisher.flatMap { walletState -> AnyPublisher<Bool, Never> in
                    guard let state = walletState else {
                        return .just(false)
                    }
                    return .just(state.isInitialised)
                }
                .eraseToAnyPublisher()
            },
            releaseState: { [holder] in
                holder.release()
            }
        )
    }
}
