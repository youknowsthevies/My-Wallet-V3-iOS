//
//  AnnouncementPreliminaryData.swift
//  Blockchain
//
//  Created by Daniel Huri on 19/07/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit

/// Contains any needed remotely fetched data before displaying announcements.
struct AnnouncementPreliminaryData {

    /// The nabu user
    let user: NabuUser
    
    /// User tiers information
    let tiers: KYC.UserTiers
    
    /// Whether the wallet has trades or not
    let hasTrades: Bool
    
    let hasPaxTransactions: Bool
    
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
    
    let pendingOrderDetails: SimpleBuyOrderDetails?

    private let isSimpleBuyAvailable: Bool
    private let simpleBuyEventCache: SimpleBuyEventCache
    
    init(user: NabuUser,
         tiers: KYC.UserTiers,
         hasTrades: Bool,
         hasPaxTransactions: Bool,
         countries: Countries,
         simpleBuyEventCache: SimpleBuyEventCache = SimpleBuyServiceProvider.default.cache,
         authenticatorType: AuthenticatorType,
         pendingOrderDetails: SimpleBuyOrderDetails?,
         isSimpleBuyAvailable: Bool) {
        self.user = user
        self.tiers = tiers
        self.hasTrades = hasTrades
        self.hasPaxTransactions = hasPaxTransactions
        self.simpleBuyEventCache = simpleBuyEventCache
        self.authenticatorType = authenticatorType
        self.pendingOrderDetails = pendingOrderDetails
        self.isSimpleBuyAvailable = isSimpleBuyAvailable
        country = countries.first { $0.code == user.address?.countryCode }
    }
}
