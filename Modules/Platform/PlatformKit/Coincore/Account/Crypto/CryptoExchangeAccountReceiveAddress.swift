//
//  CryptoExchangeAccountReceiveAddress.swift
//  PlatformKit
//
//  Created by Alex McGregor on 3/4/21.
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

public struct CryptoExchangeAccountReceiveAddress: CryptoReceiveAddress {
    public let asset: CryptoCurrency
    public let label: String
    public let address: String
    public let onTxCompleted: (TransactionResult) -> Completable
}
