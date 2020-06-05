//
//  DataRepositoryMock.swift
//  PlatformKitTests
//
//  Created by Paulo on 07/02/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import PlatformKit

class DataRepositoryMock: DataRepositoryAPI {
    var underlyingTiers = KYC.UserTiers(tiers: [])
    func fetchTiers() -> Single<KYC.UserTiers> {
        return Single.just(underlyingTiers)
    }
    
    var userSingle: Single<User> {
        user.take(1).asSingle()
    }
    
    var underlyingUser = UserMock()
    var user: Observable<User> {
        return Observable.just(underlyingUser)
    }
}
