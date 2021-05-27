// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformKit

/// Contains any needed remotely fetched data before displaying announcements.
struct AnnouncementPreliminaryData {

    /// The nabu user
    let user: NabuUser

    /// User tiers information
    let tiers: KYC.UserTiers

    let hasLinkedBanks: Bool

    let country: CountryData?

    /// The authentication type (2FA / standard)
    let authenticatorType: AuthenticatorType

    var hasLinkedExchangeAccount: Bool {
        user.hasLinkedExchangeAccount
    }

    var isKycSupported: Bool {
        country?.isKycSupported ?? false
    }

    var hasTwoFA: Bool {
        authenticatorType != .standard
    }

    var hasIncompleteBuyFlow: Bool {
        simpleBuyEventCache[.hasShownBuyScreen] && isSimpleBuyAvailable
    }

    let isSimpleBuyEligible: Bool

    let pendingOrderDetails: OrderDetails?

    /// Whether the user has a wallet balance in any account.
    let hasAnyWalletBalance: Bool

    private let isSimpleBuyAvailable: Bool
    private let simpleBuyEventCache: EventCache

    init(user: NabuUser,
         tiers: KYC.UserTiers,
         hasLinkedBanks: Bool,
         countries: [CountryData],
         simpleBuyEventCache: EventCache = resolve(),
         authenticatorType: AuthenticatorType,
         pendingOrderDetails: OrderDetails?,
         isSimpleBuyAvailable: Bool,
         isSimpleBuyEligible: Bool,
         hasAnyWalletBalance: Bool) {
        self.user = user
        self.tiers = tiers
        self.hasLinkedBanks = hasLinkedBanks
        self.simpleBuyEventCache = simpleBuyEventCache
        self.authenticatorType = authenticatorType
        self.pendingOrderDetails = pendingOrderDetails
        self.isSimpleBuyAvailable = isSimpleBuyAvailable
        self.isSimpleBuyEligible = isSimpleBuyEligible
        self.hasAnyWalletBalance = hasAnyWalletBalance
        country = countries.first { $0.code == user.address?.countryCode }
    }
}
