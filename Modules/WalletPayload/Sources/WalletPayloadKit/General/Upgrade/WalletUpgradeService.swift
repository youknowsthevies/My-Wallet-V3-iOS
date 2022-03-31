// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import ToolKit

public protocol WalletUpgradeServicing {
    /// Indicates if the wallet needs any payload upgrade.
    /// Crashes if the wallet is not initalized.
    var needsWalletUpgrade: AnyPublisher<Bool, Never> { get }

    /// Upgrades the user wallet to the most recent version.
    /// Emits the current version being upgrade.
    /// Completes when the work is done.
    /// Errors when something went wrong.
    func upgradeWallet() -> AnyPublisher<String, WalletUpgradeError>
}

private enum WalletUpgradeServiceError: Error {
    case walletNotInitialized
}

// MARK: Types

private enum PayloadVersion: String {
    case v3
    case v4
}

final class WalletUpgradeService: WalletUpgradeServicing {

    // MARK: Private Properties

    /// - Returns: Ordered array of necessary payload upgrades.
    private var necessaryUpgrades: AnyPublisher<[PayloadVersion], Never> {
        var upgrades: [PayloadVersion] = []
        guard wallet.isInitialized else {
            return .just(upgrades)
        }
        // Check if wallet was already upgrade to V3.
        if !wallet.didUpgradeToV3 {
            upgrades.append(.v3)
        }
        // Check if wallet was already upgrade to V4.
        if !wallet.didUpgradeToV4 {
            // Fetch if is necessary to upgrade to V4 based on Wallet Settings.
            return wallet.requiresV4Upgrade
                .map { requiresV4Upgrade -> [PayloadVersion] in
                    if requiresV4Upgrade {
                        upgrades.append(.v4)
                    }
                    return upgrades
                }
                .catch { _ -> AnyPublisher<[PayloadVersion], Never> in
                    .just(upgrades)
                }
                .eraseToAnyPublisher()
        }

        return .just(upgrades)
    }

    private let errorRecorder: ErrorRecording
    private let walletUpgradeJSService: WalletUpgradeJSServicing
    private let wallet: WalletUpgradingAPI

    // MARK: Init

    init(
        errorRecorder: ErrorRecording = resolve(),
        wallet: WalletUpgradingAPI = resolve(),
        walletUpgradeJSService: WalletUpgradeJSServicing = resolve()
    ) {
        self.errorRecorder = errorRecorder
        self.wallet = wallet
        self.walletUpgradeJSService = walletUpgradeJSService
    }

    // MARK: WalletUpgradeServicing

    var needsWalletUpgrade: AnyPublisher<Bool, Never> {
        guard wallet.isInitialized else {
            errorRecorder.error(WalletUpgradeServiceError.walletNotInitialized)
            return .just(false)
        }
        return necessaryUpgrades
            .map(\.isEmpty)
            .map(!)
            .eraseToAnyPublisher()
    }

    func upgradeWallet() -> AnyPublisher<String, WalletUpgradeError> {
        necessaryWorkflows()
            .setFailureType(to: WalletUpgradeError.self)
            .eraseToAnyPublisher()
            .flatMap { publishers -> AnyPublisher<String, WalletUpgradeError> in
                guard let first = publishers.first else {
                    return .failure(.errorUpgrading(version: PayloadVersion.v3.rawValue))
                }
                return concat(
                    prefix: first,
                    with: Array(publishers.dropFirst())
                )
            }
            .eraseToAnyPublisher()
    }

    // MARK: Private Methods

    private func workflow(for version: PayloadVersion) -> AnyPublisher<String, WalletUpgradeJSError> {
        switch version {
        case .v3:
            return walletUpgradeJSService.upgradeToV3()
        case .v4:
            return walletUpgradeJSService.upgradeToV4()
        }
    }

    /// Maps the list of necessary upgrades into their workflows.
    /// Because we want the version to be updated to be emitted before the work is started, we `.startWith` it.
    /// We catch any error and throw `WalletUpgradeError.errorUpgrading` instead.
    private func necessaryWorkflows() -> AnyPublisher<[AnyPublisher<String, WalletUpgradeError>], Never> {

        func workflow(for version: PayloadVersion) -> AnyPublisher<String, WalletUpgradeError> {
            provideWorkflow(walletUpgradeJSService: walletUpgradeJSService)(version)
                .replaceError(
                    with: WalletUpgradeError.errorUpgrading(
                        version: version.rawValue
                    )
                )
                .eraseToAnyPublisher()
        }

        return necessaryUpgrades
            .map { upgrades in
                upgrades.map { version in
                    workflow(for: version)
                        .prepend(version.rawValue)
                        .eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }
}

private func provideWorkflow(
    walletUpgradeJSService: WalletUpgradeJSServicing
) -> (PayloadVersion) -> AnyPublisher<String, WalletUpgradeJSError> {
    { version in
        switch version {
        case .v3:
            return walletUpgradeJSService.upgradeToV3()
        case .v4:
            return walletUpgradeJSService.upgradeToV4()
        }
    }
}

private func concat(
    prefix: AnyPublisher<String, WalletUpgradeError>,
    with publishers: [AnyPublisher<String, WalletUpgradeError>]
) -> AnyPublisher<String, WalletUpgradeError> {
    var prefix = prefix
    for publisher in publishers.dropFirst() {
        prefix = prefix
            .append(publisher)
            .eraseToAnyPublisher()
    }
    return prefix
}
