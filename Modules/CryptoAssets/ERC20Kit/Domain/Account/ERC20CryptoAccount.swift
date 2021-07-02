// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import EthereumKit
import PlatformKit
import RxSwift
import ToolKit

final class ERC20CryptoAccount: CryptoNonCustodialAccount {
    private(set) lazy var identifier: AnyHashable = "ERC20CryptoAccount.\(asset.code).\(publicKey)"
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
            .balance(for: EthereumAddress(address: publicKey)!, cryptoCurrency: asset)
            .moneyValue
    }

    var pendingBalance: Single<MoneyValue> {
        .just(.zero(currency: asset))
    }

    // TODO: Use ERC20AssetModel.products field to dictate if swap is enabled for this currency.
    private let legacySwapEnabledCurrencies: [String] = LegacyERC20Code.allCases.map(\.rawValue)

    var actions: Single<AvailableActions> {
        isFunded
            .map { [erc20Token, legacySwapEnabledCurrencies] isFunded -> AvailableActions in
                var base: AvailableActions = [.viewActivity, .receive, .send]
                if legacySwapEnabledCurrencies.contains(erc20Token.code), isFunded {
                    base.insert(.swap)
                }
                return base
            }
    }

    var receiveAddress: Single<ReceiveAddress> {
        .just(ERC20ReceiveAddress(asset: asset, address: publicKey, label: label, onTxCompleted: onTxCompleted))
    }

    private let publicKey: String
    private let erc20Token: ERC20AssetModel
    private let balanceService: ERC20BalanceServiceAPI
    private let featureFetcher: FeatureFetching
    private let fiatPriceService: FiatPriceServiceAPI

    init(
        publicKey: String,
        erc20Token: ERC20AssetModel,
        balanceService: ERC20BalanceServiceAPI = resolve(),
        featureFetcher: FeatureFetching = resolve(),
        fiatPriceService: FiatPriceServiceAPI = resolve()
    ) {
        self.publicKey = publicKey
        self.erc20Token = erc20Token
        self.asset = erc20Token.cryptoCurrency
        self.label = erc20Token.cryptoCurrency.defaultWalletName
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
             .buy,
             .sell,
             .withdraw:
            return .just(false)
        case .swap:
            guard legacySwapEnabledCurrencies.contains(erc20Token.code) else {
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
