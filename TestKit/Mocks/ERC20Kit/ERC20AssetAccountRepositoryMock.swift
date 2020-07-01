//
//  ERC20AssetAccountRepositoryMock.swift
//  ERC20KitTests
//
//  Created by Jack on 03/07/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import ERC20Kit
import PlatformKit
import RxSwift

class ERC20AssetAccountRepositoryMock: PlatformKit.AssetAccountRepositoryAPI {

    typealias Details = ERC20AssetAccountDetails

    var assetAccountDetails: Single<ERC20AssetAccountDetails> = Single.error(NSError())

    func currentAssetAccountDetails(fromCache: Bool) -> Single<ERC20AssetAccountDetails> {
        .error(NSError())
    }
}
