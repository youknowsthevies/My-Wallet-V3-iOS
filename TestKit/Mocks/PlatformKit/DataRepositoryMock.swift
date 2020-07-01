//
//  DataRepositoryMock.swift
//  PlatformKitTests
//
//  Created by Paulo on 07/02/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxSwift

class DataRepositoryMock: DataRepositoryAPI {
    var underlyingTiers = KYC.UserTiers(tiers: [])
    func fetchTiers() -> Single<KYC.UserTiers> {
        Single.just(underlyingTiers)
    }
    
    var userSingle: Single<User> {
        user.take(1).asSingle()
    }
    
    var underlyingUser = UserMock()
    var user: Observable<User> {
        Observable.just(underlyingUser)
    }
}
