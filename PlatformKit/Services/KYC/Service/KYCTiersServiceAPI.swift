//
//  KYCTiersServiceAPI.swift
//  PlatformKit
//
//  Created by Daniel Huri on 10/02/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

public protocol KYCTiersServiceAPI: class {
    
    /// Returns the cached tiers. Fetches them if they are not already cached
    var tiers: Single<KYC.UserTiers> { get }
    
    /// Fetches the tiers from remote
    func fetchTiers() -> Single<KYC.UserTiers>
}
