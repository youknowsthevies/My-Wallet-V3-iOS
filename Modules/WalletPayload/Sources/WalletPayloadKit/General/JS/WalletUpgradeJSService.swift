// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import CombineSchedulers
import DIKit
import Localization
import ToolKit

protocol WalletUpgradeJSServicing: AnyObject {
    /// Upgrades the wallet to V3 and emits "V3"
    /// Fails with `WalletUpgradeError.failedV3Upgrade` if anything went wrong.
    func upgradeToV3() -> AnyPublisher<String, WalletUpgradeJSError>

    /// Upgrades the wallet to V4 and emits "V4"
    /// Fails with `WalletUpgradeError.failedV4Upgrade` if anything went wrong.
    func upgradeToV4() -> AnyPublisher<String, WalletUpgradeJSError>
}

enum WalletUpgradeJSError: Error {
    case failedV3Upgrade
    case failedV4Upgrade
}

final class WalletUpgradeJSService: WalletUpgradeJSServicing {

    // MARK: Types

    private enum JSCallback {
        enum V3Payload: NSString {
            case didUpgrade = "objc_upgrade_V3_success"
            case didFail = "objc_upgrade_V3_error"
        }

        enum V4Payload: NSString {
            case didUpgrade = "objc_upgrade_V4_success"
            case didFail = "objc_upgrade_V4_error"
        }
    }

    private enum JSFunction {
        enum V3Payload {
            static func upgrade(with newWalletName: String) -> String {
                "MyWalletPhone.upgradeToV3(\"\(newWalletName)\")"
            }
        }

        enum V4Payload: String {
            case upgrade = "MyWalletPhone.upgradeToV4()"
        }
    }

    // MARK: Private Properties

    private let contextProvider: JSContextProviderAPI
    private let queue: AnySchedulerOf<DispatchQueue>

    // MARK: Init

    init(
        contextProvider: JSContextProviderAPI = resolve(),
        queue: AnySchedulerOf<DispatchQueue> = .main
    ) {
        self.contextProvider = contextProvider
        self.queue = queue
    }

    // MARK: WalletUpgradeJSServicing

    func upgradeToV3() -> AnyPublisher<String, WalletUpgradeJSError> {
        Deferred { [contextProvider] in
            Future<String, WalletUpgradeJSError> { promise in
                let context = contextProvider.jsContext
                let walletName = LocalizationConstants.Account.myWallet
                context.invokeOnce(
                    functionBlock: {
                        promise(.success("V3"))
                    },
                    forJsFunctionName: JSCallback.V3Payload.didUpgrade.rawValue
                )
                context.invokeOnce(
                    functionBlock: {
                        promise(.failure(WalletUpgradeJSError.failedV3Upgrade))
                    },
                    forJsFunctionName: JSCallback.V3Payload.didFail.rawValue
                )
                context.evaluateScriptCheckIsOnMainQueue(JSFunction.V3Payload.upgrade(with: walletName))
            }
        }
        .subscribe(on: queue)
        .eraseToAnyPublisher()
    }

    func upgradeToV4() -> AnyPublisher<String, WalletUpgradeJSError> {
        Deferred { [contextProvider] in
            Future<String, WalletUpgradeJSError> { promise in
                let context = contextProvider.jsContext
                context.invokeOnce(
                    functionBlock: {
                        promise(.success("V4"))
                    },
                    forJsFunctionName: JSCallback.V4Payload.didUpgrade.rawValue
                )
                context.invokeOnce(
                    functionBlock: {
                        promise(.failure(WalletUpgradeJSError.failedV4Upgrade))
                    },
                    forJsFunctionName: JSCallback.V4Payload.didFail.rawValue
                )
                context.evaluateScriptCheckIsOnMainQueue(JSFunction.V4Payload.upgrade.rawValue)
            }
        }
        .subscribe(on: queue)
        .eraseToAnyPublisher()
    }
}
