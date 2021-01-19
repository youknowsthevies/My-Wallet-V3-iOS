//
//  FeeService.swift
//  Blockchain
//
//  Created by Jack on 27/03/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import BitcoinChainKit
import DIKit
import EthereumKit
import PlatformKit
import RxSwift
import StellarKit

public protocol FeeServiceAPI {
    /// This pulls from a Blockchain.info endpoint that serves up
    /// current BTC transaction fees. We use this in order to inject a `fee` value
    /// into the JS. Only `Swap` uses priority fees.
    var bitcoin: Single<BitcoinChainTransactionFee<BitcoinToken>> { get }
    
    /// This pulls from a Blockchain.info endpoint that serves up
    /// current BTC transaction fees. We use this in order to inject a `fee` value
    /// into the JS. Only `Swap` uses priority fees.
    var bitcoinCash: Single<BitcoinChainTransactionFee<BitcoinCashToken>> { get }

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

    public var bitcoin: Single<BitcoinChainTransactionFee<BitcoinToken>> {
        bitcoinFeeService.fees
    }
    
    public var bitcoinCash: Single<BitcoinChainTransactionFee<BitcoinCashToken>> {
        bitcoinCashFeeService.fees
    }

    public var ethereum: Single<EthereumTransactionFee> {
        ethereumFeeService.fees
    }

    public var stellar: Single<StellarTransactionFee> {
        stellarFeeService.fees
    }

    // MARK: - Private properties

    private let bitcoinFeeService: CryptoFeeService<BitcoinChainTransactionFee<BitcoinToken>>
    private let bitcoinCashFeeService: CryptoFeeService<BitcoinChainTransactionFee<BitcoinCashToken>>
    private let ethereumFeeService: CryptoFeeService<EthereumTransactionFee>
    private let stellarFeeService: AnyCryptoFeeService<StellarTransactionFee>

    init(bitcoinFeeService: CryptoFeeService<BitcoinChainTransactionFee<BitcoinToken>> = resolve(),
         bitcoinCashFeeService: CryptoFeeService<BitcoinChainTransactionFee<BitcoinCashToken>> = resolve(),
         ethereumFeeService: CryptoFeeService<EthereumTransactionFee> = resolve(),
         stellarFeeService: AnyCryptoFeeService<StellarTransactionFee> = resolve()) {
        self.bitcoinFeeService = bitcoinFeeService
        self.bitcoinCashFeeService = bitcoinCashFeeService
        self.ethereumFeeService = ethereumFeeService
        self.stellarFeeService = stellarFeeService
    }
}
