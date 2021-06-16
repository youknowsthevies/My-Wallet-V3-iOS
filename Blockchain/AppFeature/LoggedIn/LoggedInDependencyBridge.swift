// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DashboardUIKit
import PlatformUIKit
import SettingsUIKit

/// This protocol conforms to a set of certain protocols that were used as part of the
/// older `AppCoordinator` class which was passed around using it's `shared` property
/// This attempts to bridge the two worlds of the `LoggedInHostingController` and any
/// class that uses the extended protocols.
protocol LoggedInBridge: DrawerRouting,
                         TabSwapping,
                         CurrencyRouting,
                         CashIdentityVerificationAnnouncementRouting,
                         InterestIdentityVerificationAnnouncementRouting,
                         AppCoordinating,
                         WalletOperationsRouting { }

protocol LoggedInDependencyBridgeAPI {
    /// Registers the bridge
    func register(bridge: LoggedInBridge)
    /// Unregisters the bridge
    func unregister()

    /// Provides `DrawerRouting` methods
    func resolveDrawerRouting() -> DrawerRouting
    /// Provides `TabSwapping` methods
    func resolveTabSwapping() -> TabSwapping
    /// Provides `CurrencyRouting` methods
    func resolveCurrencyRouting() -> CurrencyRouting
    /// Provides `CashIdentityVerificationAnnouncementRouting` methods
    func resolveCashIdentityVerificationAnnouncementRouting() -> CashIdentityVerificationAnnouncementRouting
    /// Provides `InterestIdentityVerificationAnnouncementRouting` methods
    func resolveInterestIdentityVerificationAnnouncementRouting() -> InterestIdentityVerificationAnnouncementRouting
    /// Provides `AppCoordinating` methods
    func resolveAppCoordinating() -> AppCoordinating
    /// Provides `CurrencyRouting & TabSwapping` methods
    func resolveCurrencyRoutingAndTabSwapping() -> CurrencyRouting & TabSwapping
    /// Provides `WalletOperationsRouting` methods
    func resolveWalletOperationsRouting() -> WalletOperationsRouting
}

final class LoggedInDependencyBridge: LoggedInDependencyBridgeAPI {

    private weak var hostingControllerBridge: LoggedInBridge?

    init() { }

    func register(bridge: LoggedInBridge) {
        hostingControllerBridge = bridge
    }

    func unregister() {
        hostingControllerBridge = nil
    }

    func resolveDrawerRouting() -> DrawerRouting {
        resolve() as DrawerRouting
    }

    func resolveTabSwapping() -> TabSwapping {
        resolve() as TabSwapping
    }

    func resolveCurrencyRouting() -> CurrencyRouting {
        resolve() as CurrencyRouting
    }

    func resolveCashIdentityVerificationAnnouncementRouting() -> CashIdentityVerificationAnnouncementRouting {
        resolve() as CashIdentityVerificationAnnouncementRouting
    }

    func resolveInterestIdentityVerificationAnnouncementRouting() -> InterestIdentityVerificationAnnouncementRouting {
        resolve() as InterestIdentityVerificationAnnouncementRouting
    }

    func resolveAppCoordinating() -> AppCoordinating {
        resolve() as AppCoordinating
    }

    func resolveCurrencyRoutingAndTabSwapping() -> CurrencyRouting & TabSwapping {
        resolve() as CurrencyRouting & TabSwapping
    }

    func resolveWalletOperationsRouting() -> WalletOperationsRouting {
        resolve() as WalletOperationsRouting
    }

    /// Resolves the underlying bridge with a type
    /// - precondition: The bridge should conform to the type
    /// - Returns: The underlying bridge as a specific protocol type
    private func resolve<T>() -> T {
        precondition(hostingControllerBridge is T)
        return hostingControllerBridge as! T
    }
}
