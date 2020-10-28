//
//  ERC20CryptoAccount.swift
//  ERC20Kit
//
//  Created by Paulo on 07/08/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import EthereumKit
import Localization
import PlatformKit
import RxSwift
import ToolKit

final class ERC20CryptoAccount<Token: ERC20Token>: CryptoNonCustodialAccount {
    private typealias LocalizedString = LocalizationConstants.Account
    
    let id: String
    let label: String
    let asset: CryptoCurrency = Token.assetType
    let isDefault: Bool = true

    var balance: Single<MoneyValue> {
        balanceFetching
            .balanceMoney
    }
    
    var pendingBalance: Single<MoneyValue> {
        balanceFetching
            .pendingBalanceMoney
    }

    private(set) lazy var actions: AvailableActions = {
        var base: AvailableActions = [.viewActivity, .receive]
        if Token.nonCustodialSendSupport {
            base.insert(.send)
            base.insert(.swap)
        }
        return base
    }()

    var receiveAddress: Single<ReceiveAddress> {
        .just(ERC20ReceiveAddress(asset: asset, address: id, label: label))
    }

    private let balanceFetching: SingleAccountBalanceFetching
    private let exchangeService: PairExchangeServiceAPI
    
    init(id: String,
         balanceProviding: BalanceProviding = resolve(),
         exchangeProviding: ExchangeProviding = resolve()) {
        self.id = id
        self.label = Token.assetType.defaultWalletName
        self.exchangeService = exchangeProviding[Token.assetType]
        self.balanceFetching = balanceProviding[Token.assetType.currency].wallet
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
