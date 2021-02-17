//
//  AssetAccountRepositoryAPI.swift
//  Blockchain
//
//  Created by Paulo on 20/02/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxSwift

protocol AssetAccountRepositoryAPI: AnyObject {
    var accounts: Single<[AssetAccount]> { get }
    func defaultAccount(for assetType: CryptoCurrency) -> Single<AssetAccount>
}
