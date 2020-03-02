//
//  KYCClientAPI.swift
//  PlatformKit
//
//  Created by Daniel Huri on 10/02/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

public protocol KYCClientAPI: class {
    func tiers(with token: String) -> Single<KYC.UserTiers>
}
