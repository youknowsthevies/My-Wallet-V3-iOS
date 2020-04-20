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
    
    let country: KYCCountry?
            
    /// The authentication type (2FA / standard)
    let authenticatorType: AuthenticatorType
    
    var hasLinkedExchangeAccount: Bool {
        return user.hasLinkedExchangeAccount
    }
    
    var isKycSupported: Bool {
        return country?.isKycSupported ?? false
    }
    
    var hasTwoFA: Bool {
        return authenticatorType != .standard
    }

    var hasReceivedBlockstackAirdrop: Bool {
        guard let campaign = airdropCampaigns.campaign(by: .blockstack) else {
            return false
        }
        return campaign.currentState == .received
    }

    var pendingSimpleBuyOrderAssetType: CryptoCurrency? {
        simpleBuyCheckoutData?.cryptoCurrency
    }

    var hasIncompleteBuyFlow: Bool {
        simpleBuyEventCache[.hasShownBuyScreen] && isSimpleBuyAvailable
    }

    private let isSimpleBuyAvailable: Bool
    private let airdropCampaigns: AirdropCampaigns
    private let simpleBuyCheckoutData: SimpleBuyCheckoutData?
    private let simpleBuyEventCache: SimpleBuyEventCache
    
    init(user: NabuUser,
         tiers: KYC.UserTiers,
         airdropCampaigns: AirdropCampaigns,
         hasTrades: Bool,
         hasPaxTransactions: Bool,
         countries: Countries,
         simpleBuyEventCache: SimpleBuyEventCache = SimpleBuyServiceProvider.default.cache,
         authenticatorType: AuthenticatorType,
         simpleBuyCheckoutData: SimpleBuyCheckoutData?,
         isSimpleBuyAvailable: Bool) {
        self.airdropCampaigns = airdropCampaigns
        self.user = user
        self.tiers = tiers
        self.hasTrades = hasTrades
        self.hasPaxTransactions = hasPaxTransactions
        self.simpleBuyEventCache = simpleBuyEventCache
        self.authenticatorType = authenticatorType
        self.simpleBuyCheckoutData = simpleBuyCheckoutData
        self.isSimpleBuyAvailable = isSimpleBuyAvailable
        country = countries.first { $0.code == user.address?.countryCode }
    }
}
