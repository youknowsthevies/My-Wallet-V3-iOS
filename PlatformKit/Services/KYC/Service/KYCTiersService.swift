//
//  KYCTiersService.swift
//  PlatformKit
//
//  Created by Daniel Huri on 10/02/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import ToolKit

public final class KYCTiersService: KYCTiersServiceAPI {
    
    // MARK: - Exposed Properties
    
    public var tiers: Single<KYC.UserTiers> {
        return cachedTiers.valueSingle
    }
        
    // MARK: - Private Properties
    
    private let cachedTiers = CachedValue<KYC.UserTiers>(configuration: .onSubscriptionAndLogin())
    
    // MARK: - Setup
    
    public init(client: KYCClientAPI = KYCClient(),
                authenticationService: NabuAuthenticationServiceAPI) {
        cachedTiers.setFetch {
            authenticationService
                .tokenString
                .flatMap { token -> Single<KYC.UserTiers> in
                    client.tiers(with: token)
                }
        }
    }
    
    public func fetchTiers() -> Single<KYC.UserTiers> {
        cachedTiers.fetchValue
    }
}
