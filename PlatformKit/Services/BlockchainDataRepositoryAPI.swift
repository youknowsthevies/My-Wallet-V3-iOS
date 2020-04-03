//
//  BlockchainDataRepositoryAPI.swift
//  PlatformKit
//
//  Created by Paulo on 06/02/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

public protocol DataRepositoryAPI {
    var userSingle: Single<User> { get }
    var user: Observable<User> { get }
    func fetchTiers() -> Single<KYC.UserTiers>
}
