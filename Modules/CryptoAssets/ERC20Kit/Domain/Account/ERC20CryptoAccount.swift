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
        balanceService
            .balance(for: EthereumAddress(stringLiteral: id), cryptoCurrency: asset)
            .moneyValue
    }

    var pendingBalance: Single<MoneyValue> {
        .just(.zero(currency: asset))
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
    private let balanceService: ERC20BalanceServiceAPI
    private let featureFetcher: FeatureFetching
    private let fiatPriceService: FiatPriceServiceAPI

    init(
        id: String,
        erc20Token: ERC20Token,
        balanceService: ERC20BalanceServiceAPI = resolve(),
        featureFetcher: FeatureFetching = resolve(),
        fiatPriceService: FiatPriceServiceAPI = resolve()
    ) {
        self.id = id
        self.erc20Token = erc20Token
        self.asset = erc20Token.assetType
        self.label = erc20Token.assetType.defaultWalletName
        self.balanceService = balanceService
        self.featureFetcher = featureFetcher
        self.fiatPriceService = fiatPriceService
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

    func balancePair(fiatCurrency: FiatCurrency) -> Single<MoneyValuePair> {
        Single
            .zip(
                fiatPriceService.getPrice(cryptoCurrency: asset, fiatCurrency: fiatCurrency),
                balance
            )
            .map { (fiatPrice, balance) in
                try MoneyValuePair(base: balance, exchangeRate: fiatPrice)
            }
    }

    func balancePair(fiatCurrency: FiatCurrency, at date: Date) -> Single<MoneyValuePair> {
        Single
            .zip(
                fiatPriceService.getPrice(cryptoCurrency: asset, fiatCurrency: fiatCurrency, date: date),
                balance
            )
            .map { (fiatPrice, balance) in
                try MoneyValuePair(base: balance, exchangeRate: fiatPrice)
            }
    }
}
