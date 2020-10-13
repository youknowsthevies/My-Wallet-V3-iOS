//
//  FeeService.swift
//  Blockchain
//
//  Created by Jack on 27/03/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import BitcoinKit
import DIKit
import EthereumKit
import PlatformKit
import RxSwift
import StellarKit

public protocol FeeServiceAPI {
    /// This pulls from a Blockchain.info endpoint that serves up
    /// current BTC transaction fees. We use this in order to inject a `fee` value
    /// into the JS. Only `Swap` uses priority fees.
    var bitcoin: Single<BitcoinTransactionFee> { get }
    
    /// This pulls from a Blockchain.info endpoint that serves up
    /// current BTC transaction fees. We use this in order to inject a `fee` value
    /// into the JS. Only `Swap` uses priority fees.
    var bitcoinCash: Single<BitcoinCashTransactionFee> { get }

    /// This pulls from a Blockchain.info endpoint that serves up
    /// current ETH transaction fees. We use this in order to inject a `fee` value
    /// into the JS. Only `Swap` uses priority fees.
    var ethereum: Single<EthereumTransactionFee> { get }

    /// This pulls from a Blockchain.info endpoint that serves up
    /// current XLM transaction fees. We use this in order to inject a `fee` value
    /// into the JS. Only `Swap` uses priority fees.
    var stellar: Single<StellarTransactionFee> { get }
}

public final class FeeService: FeeServiceAPI {
    static let shared = FeeService()

    // MARK: - FeeServiceAPI

    public var bitcoin: Single<BitcoinTransactionFee> {
        bitcoinFeeService.fees
    }
    
    public var bitcoinCash: Single<BitcoinCashTransactionFee> {
        bitcoinCashFeeService.fees
    }

    public var ethereum: Single<EthereumTransactionFee> {
        ethereumFeeService.fees
    }

    public var stellar: Single<StellarTransactionFee> {
        stellarFeeService.fees
    }

    // MARK: - Private properties

    private let bitcoinFeeService: CryptoFeeService<BitcoinTransactionFee>
    private let bitcoinCashFeeService: CryptoFeeService<BitcoinCashTransactionFee>
    private let ethereumFeeService: CryptoFeeService<EthereumTransactionFee>
    private let stellarFeeService: CryptoFeeService<StellarTransactionFee>

    init(bitcoinFeeService: CryptoFeeService<BitcoinTransactionFee> = resolve(),
         bitcoinCashFeeService: CryptoFeeService<BitcoinCashTransactionFee> = resolve(),
         ethereumFeeService: CryptoFeeService<EthereumTransactionFee> = resolve(),
         stellarFeeService: CryptoFeeService<StellarTransactionFee> = resolve()) {
        self.bitcoinFeeService = bitcoinFeeService
        self.bitcoinCashFeeService = bitcoinCashFeeService
        self.ethereumFeeService = ethereumFeeService
        self.stellarFeeService = stellarFeeService
    }
}
