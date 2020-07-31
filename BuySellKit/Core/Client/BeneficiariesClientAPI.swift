//
//  BeneficiariesClientAPI.swift
//  BuySellKit
//
//  Created by Daniel on 14/07/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxSwift

protocol BeneficiariesClientAPI: AnyObject {
    var beneficiaries: Single<[BeneficiaryResponse]> { get }
    func deleteBank(by id: String) -> Completable
}
