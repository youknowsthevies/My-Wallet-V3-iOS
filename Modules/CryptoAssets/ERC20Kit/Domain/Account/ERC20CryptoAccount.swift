// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import EthereumKit
import PlatformKit
import RxSwift
import ToolKit

final class ERC20CryptoAccount: CryptoNonCustodialAccount {
    let id: String
    let label: String
    let asset: CryptoCurrency
    let isDefault: Bool = true

    func createTransactionEngine() -> Any {
        ERC20OnChainTransactionEngineFactory(erc20Token: erc20Token)
    }

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
            .map { [erc20Token] isFunded -> AvailableActions in
                var base: AvailableActions = [.viewActivity, .receive, .send]
                if erc20Token.nonCustodialTransactionSupport.contains(.swap), isFunded {
                    base.insert(.swap)
                }
                return base
            }
    }

    var receiveAddress: Single<ReceiveAddress> {
        .just(ERC20ReceiveAddress(asset: asset, address: id, label: label, onTxCompleted: onTxCompleted))
    }

    private let erc20Token: ERC20Token
    private let balanceFetching: SingleAccountBalanceFetching
    private let exchangeService: PairExchangeServiceAPI
    private let featureFetcher: FeatureFetching

    init(id: String,
         erc20Token: ERC20Token,
         balanceProviding: BalanceProviding = resolve(),
         exchangeProviding: ExchangeProviding = resolve(),
         featureFetcher: FeatureFetching = resolve()) {
        self.id = id
        self.erc20Token = erc20Token
        self.asset = erc20Token.assetType
        self.label = erc20Token.assetType.defaultWalletName
        self.exchangeService = exchangeProviding[erc20Token.assetType]
        self.balanceFetching = balanceProviding[erc20Token.assetType.currency].wallet
        self.featureFetcher = featureFetcher
    }

    func can(perform action: AssetAction) -> Single<Bool> {
        switch action {
        case .receive,
             .viewActivity:
            return .just(true)
        case .send:
            return .just(true)
        case .deposit,
             .sell,
             .withdraw:
            return .just(false)
        case .swap:
            guard erc20Token.nonCustodialTransactionSupport.contains(.swap) else {
                return .just(false)
            }
            return isFunded
        }
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
