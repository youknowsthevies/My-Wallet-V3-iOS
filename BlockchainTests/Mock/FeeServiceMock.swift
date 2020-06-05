//  FeeServiceMock.swift
//  BlockchainTests
//
//  Created by Paulo on 04/06/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import BitcoinKit
import EthereumKit
import StellarKit
import RxSwift
import Blockchain

class FeeServiceMock: FeeServiceAPI {
    var bitcoin: Single<BitcoinTransactionFee> = Single.error(NSError())
    var ethereum: Single<EthereumTransactionFee> = Single.error(NSError())
    var stellar: Single<StellarTransactionFee> = Single.error(NSError())
    var bitcoinCash: Single<BitcoinCashTransactionFee> = Single.error(NSError())
}
