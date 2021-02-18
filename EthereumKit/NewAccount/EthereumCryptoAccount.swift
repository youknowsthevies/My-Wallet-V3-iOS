//
//  EthereumCryptoAccount.swift
//  EthereumKit
//
//  Created by Paulo on 06/08/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import PlatformKit
import RxSwift
import ToolKit

final class EthereumCryptoAccount: CryptoNonCustodialAccount {
    let id: String
    let label: String
    let asset: CryptoCurrency
    let isDefault: Bool = true
    
    var actionableBalance: Single<MoneyValue> {
        balance
    }

    var balance: Single<MoneyValue> {
        balanceFetching
            .balanceMoney
    }

    var pendingBalance: Single<MoneyValue> {
        balanceFetching
            .pendingBalanceMoney
    }
    
    var actions: Single<AvailableActions> {
        isFunded
            .map { isFunded -> AvailableActions in
                var base: AvailableActions = [.viewActivity, .receive, .send]
                if isFunded {
                    base.insert(.swap)
                }
                return base
            }
    }

    var receiveAddress: Single<ReceiveAddress> {
        .just(EthereumReceiveAddress(address: id, label: label, onTxCompleted: onTxCompleted))
    }

    private let balanceFetching: SingleAccountBalanceFetching
    private let exchangeService: PairExchangeServiceAPI

    init(id: String,
         label: String? = nil,
         balanceProviding: BalanceProviding = resolve(),
         exchangeProviding: ExchangeProviding = resolve()) {
        let asset = CryptoCurrency.ethereum
        self.asset = asset
        self.id = id
        self.exchangeService = exchangeProviding[asset]
        self.balanceFetching = balanceProviding[asset.currency].wallet
        self.label = label ?? asset.defaultWalletName
    }

    func fiatBalance(fiatCurrency: FiatCurrency) -> Single<MoneyValue> {
        Single
            .zip(
                exchangeService.fiatPrice.take(1).asSingle(),
                balance
            ) { (exchangeRate: $0, balance: $1) }
            .map { try MoneyValuePair(base: $0.balance, exchangeRate: $0.exchangeRate.moneyValue) }
            .map(\.quote)
    }
}
