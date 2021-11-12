// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import ToolKit

/// Useful top-level method to check whether nativeWallet feature flag is enabled or not
/// - Parameters:
///   - service: A `FeatureFlagsServiceAPI`
/// - Returns: An `AnyPublisher<Bool, Never>` that determines whether the flag is enabled or not
public func nativeWalletFlagEnabled(
    service: FeatureFlagsServiceAPI = resolve()
) -> AnyPublisher<Bool, Never> {
    service.isEnabled(.local(.nativeWalletPayload))
}

/// Useful top-left method that output an Either type of values old and new.
/// - Parameters:
///   - old: An old implementation to be used
///   - new: A new  implementation to be used
/// - Returns: `Either<Old, New>`
public func nativeWalletEnabledUseImpl<Old, New>(
    old: Old,
    new: New
) -> AnyPublisher<Either<Old, New>, Never> {
    nativeWalletFlagEnabled()
        .map { isEnabled in
            guard isEnabled else {
                return Either.left(old)
            }
            return Either.right(new)
        }
        .eraseToAnyPublisher()
}

public typealias NativeWalletEnabledUseImpl<Old, New> = (Old, New) -> AnyPublisher<Either<Old, New>, Never>

/// Temporary helper `Either` type
public enum Either<Left, Right> {
    case left(Left)
    case right(Right)

    var left: Left? {
        switch self {
        case .left(let left):
            return left
        case .right:
            return nil
        }
    }

    var right: Right? {
        switch self {
        case .left:
            return nil
        case .right(let right):
            return right
        }
    }

    public func `if`<Other>(
        left applyLeft: (Left) -> Other,
        right applyRight: (Right) -> Other
    ) -> Other {
        switch self {
        case .left(let value):
            return applyLeft(value)
        case .right(let value):
            return applyRight(value)
        }
    }
}
