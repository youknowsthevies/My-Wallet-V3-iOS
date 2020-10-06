//
//  CryptoNonCustodialAccount.swift
//  PlatformKit
//
//  Created by Paulo on 03/08/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

public protocol CryptoNonCustodialAccount: CryptoAccount { }

extension CryptoNonCustodialAccount {
    public var accountType: SingleAccountType {
        .nonCustodial
    }
    
    public var isFunded: Single<Bool> {
        balance
            .map { $0.isPositive }
    }
}
