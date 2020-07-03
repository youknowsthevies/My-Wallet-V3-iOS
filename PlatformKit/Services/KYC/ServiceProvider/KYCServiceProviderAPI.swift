//
//  KYCServiceProviderAPI.swift
//  PlatformKit
//
//  Created by Daniel Huri on 10/02/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

public protocol KYCServiceProviderAPI: class {
    
    /// The tiers service - it fetches and caches the tiers
    var tiers: KYCTiersServiceAPI { get }
    
    /// Thwe user service - it fetches and caches the user
    var user: NabuUserServiceAPI { get }
    
    /// Returns a service that polls the tiers until a given one is confirmed
    var tiersPollingService: KYCTierUpdatePollingService { get }
}
