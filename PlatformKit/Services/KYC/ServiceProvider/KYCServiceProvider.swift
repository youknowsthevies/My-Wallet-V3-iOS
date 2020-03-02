//
//  KYCServiceProvider.swift
//  PlatformKit
//
//  Created by Daniel Huri on 10/02/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

public final class KYCServiceProvider: KYCServiceProviderAPI {

    // MARK: - Properties
        
    public let tiers: KYCTiersServiceAPI
    
    /// Computes the polling service
    public var tiersPollingService: KYCTierUpdatePollingService {
        KYCTierUpdatePollingService(tiersService: tiers)
    }
    
    // MARK: - Setup
    
    public init(client: KYCClientAPI = KYCClient(),
                authenticationService: NabuAuthenticationServiceAPI) {
        tiers = KYCTiersService(
            client: client,
            authenticationService: authenticationService
        )
    }
}

