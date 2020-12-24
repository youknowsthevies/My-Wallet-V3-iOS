//
//  LInkedBanksClientAPI.swift
//  BuySellKit
//
//  Created by Dimitrios Chatzieleftheriou on 08/12/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

protocol LinkedBanksClientAPI: AnyObject {
    func linkedBanks() -> Single<[LinkedBankResponse]>
}
