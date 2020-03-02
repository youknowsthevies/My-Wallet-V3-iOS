//
//  CustodyWithdrawalClientAPI.swift
//  PlatformKit
//
//  Created by AlexM on 2/12/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

public protocol CustodyWithdrawalClientAPI: class {
    /// Make a withdrawal with a `SimpleBuyWithdrawalRequest`.
    /// A `403` means a withdrawal is pending.
    /// A `409` means you have insufficient funds for the withdrawal. 
    func withdraw(cryptoValue: CryptoValue, destination: String, authToken: String) -> Single<CustodialWithdrawalResponse>
}
