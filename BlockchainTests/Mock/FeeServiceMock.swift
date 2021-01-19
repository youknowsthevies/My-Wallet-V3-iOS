//  FeeServiceMock.swift
//  BlockchainTests
//
//  Created by Paulo on 04/06/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import BitcoinChainKit
import Blockchain
import EthereumKit
import PlatformKit
import RxSwift
import StellarKit

class FeeServiceMock: FeeServiceAPI {
    var bitcoin: Single<BitcoinChainTransactionFee<BitcoinToken>> = Single.error(NSError())
    var ethereum: Single<EthereumTransactionFee> = Single.error(NSError())
    var stellar: Single<StellarTransactionFee> = Single.error(NSError())
    var bitcoinCash: Single<BitcoinChainTransactionFee<BitcoinCashToken>> = Single.error(NSError())
}
