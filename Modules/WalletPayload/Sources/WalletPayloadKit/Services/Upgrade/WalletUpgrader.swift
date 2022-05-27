// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation

enum WalletPayloadVersion: Int, Comparable {
    case v3 = 3
    case v4 = 4

    static func < (lhs: WalletPayloadVersion, rhs: WalletPayloadVersion) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

protocol WalletUpgraderAPI {
    /// Checks if upgrade is needed on the given wrapper
    /// - Parameter wrapper: A `Wrapper` to be evaluated for an upgrade
    /// - Returns: `true` if needs upgrade, otherwise `false`
    func upgradedNeeded(wrapper: Wrapper) -> Bool

    /// Runs the upgrades
    /// - Parameter wrapper: The current wallet `Wrapper` to be upgraded
    /// - Returns: `AnyPublisher<Wrapper, WalletUpgradeError>`
    func performUpgrade(wrapper: Wrapper) -> AnyPublisher<Wrapper, WalletUpgradeError>
}

/// Responsible to upgrading the Wrapper and Wallet to the latest support version
///
/// Currently supported version is `4`.
/// `Version 2` attributes:
///     - non HD Wallet
/// `Version 3` attributes:
///     - HD Wallet
/// `Version 4` attributes:
///     - HD Wallet with segwit support
///
final class WalletUpgrader: WalletUpgraderAPI {

    private let workflows: [WalletUpgradeWorkflow]

    init(workflows: [WalletUpgradeWorkflow]) {
        self.workflows = workflows
    }

    func upgradedNeeded(
        wrapper: Wrapper
    ) -> Bool {
        !requiredWorkflows(wrapper: wrapper).isEmpty
    }

    func performUpgrade(
        wrapper: Wrapper
    ) -> AnyPublisher<Wrapper, WalletUpgradeError> {
        let initialValue = Just(wrapper)
            .setFailureType(to: WalletUpgradeError.self)
            .eraseToAnyPublisher()
        /// For each workflow needed, run the upgrade using `reduce(_:)`
        /// By using `reduce(_:)` we keep a state of the latest upgraded `Wrapper` value
        /// and once the upstream (aka `upgradeWorkflowsNeeded(for:)`) finishes
        /// we'll receive the latest value.
        return upgradeWorkflowsNeeded(for: wrapper)
            .reduce(initialValue) { wrapper, workflow -> AnyPublisher<Wrapper, WalletUpgradeError> in
                wrapper.flatMap { value -> AnyPublisher<Wrapper, WalletUpgradeError> in
                    // run the upgrade
                    workflow(value)
                }
                .eraseToAnyPublisher()
            }
            .flatMap { $0 }
            .eraseToAnyPublisher()
    }

    /// Determines the necessary migration workflows we need to go through for the wallet to be the latest version
    /// - Parameter wrapper: The current wallet `Wrapper` to be upgraded
    /// - Returns: `AnyPublisher<[UpgradeWorkflowMethod], WalletUpgradeError>`
    private func upgradeWorkflowsNeeded(
        for wrapper: Wrapper
    ) -> Publishers.Sequence<[UpgradeWorkflowMethod], Never> {
        requiredWorkflows(wrapper: wrapper)
            .map { $0.upgrade(wrapper:) }
            .publisher
    }

    private func requiredWorkflows(
        wrapper: Wrapper
    ) -> [WalletUpgradeWorkflow] {
        workflows
            .filter { workflow in
                workflow.shouldPerformUpgrade(wrapper: wrapper)
            }
    }
}
