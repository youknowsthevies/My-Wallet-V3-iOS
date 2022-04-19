// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation

typealias UpgradeWorkflowMethod = (Wrapper) -> AnyPublisher<Wrapper, WalletUpgradeError>

/// Types adopting `WalletUpgradeWorkflow` should provide the following
///  - Verify if upgrade is needed
///  - Perform an upgrade
protocol WalletUpgradeWorkflow {
    /// The `WalletPayloadVersion` the workflow upgrades to
    static var supportedVersion: WalletPayloadVersion { get }
    /// Determines of the passed wrappers required to be updated with the current workflow
    ///
    /// - Parameter wrapper: A `Wrapper` to be checked
    /// - Returns: `true` if upgrade is required, otherwise false
    func shouldPerformUpgrade(wrapper: Wrapper) -> Bool

    /// Performs the upgrade to the given `Wrapper`
    /// - Parameter wrapper: A `Wrapper` to be upgraded
    /// - Returns: `AnyPublisher<Wrapper, WalletUpgradeError>`
    func upgrade(wrapper: Wrapper) -> AnyPublisher<Wrapper, WalletUpgradeError>
}
