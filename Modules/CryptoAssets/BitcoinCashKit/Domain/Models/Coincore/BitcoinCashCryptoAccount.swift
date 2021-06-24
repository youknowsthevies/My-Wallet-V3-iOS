// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BitcoinChainKit
import DIKit
import Localization
import PlatformKit
import RxSwift
import ToolKit

final class BitcoinCashCryptoAccount: CryptoNonCustodialAccount {
    private typealias LocalizedString = LocalizationConstants.Account

    let id: String
    let label: String
    let asset: CryptoCurrency = .bitcoinCash
    let isDefault: Bool

    func createTransactionEngine() -> Any {
        BitcoinOnChainTransactionEngineFactory<BitcoinCashToken>()
    }

    var pendingBalance: Single<MoneyValue> {
        .just(.zero(currency: .bitcoinCash))
    }

    var balance: Single<MoneyValue> {
        balanceService
            .balance(for: xPub)
            .moneyValue
    }

    var actionableBalance: Single<MoneyValue> {
        balance
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
        let receiveAddress: Single<String> = bridge.receiveAddress(forXPub: id)
        let account: Single<BitcoinCashWalletAccount> = bridge
            .wallets
            .map { [xPub] wallets in
                wallets.filter { $0.publicKey == xPub }
            }
            .map { accounts -> BitcoinCashWalletAccount in
                guard let account = accounts.first else {
                    throw PlatformKitError.illegalStateException(message: "Expected a BitcoinCashWalletAccount")
                }
                return account
            }

        return Single.zip(receiveAddress, account)
            .map { [label, onTxCompleted] (address, account) -> ReceiveAddress in
                BitcoinChainReceiveAddress<BitcoinCashToken>(
                    address: address,
                    label: label,
                    onTxCompleted: onTxCompleted,
                    index: Int32(account.index)
                )
            }
    }

    private let xPub: XPub
    private let hdAccountIndex: Int
    private let balanceService: BalanceServiceAPI
    private let fiatPriceService: FiatPriceServiceAPI
    private let bridge: BitcoinCashWalletBridgeAPI

    init(xPub: XPub,
         label: String?,
         isDefault: Bool,
         hdAccountIndex: Int,
         fiatPriceService: FiatPriceServiceAPI = resolve(),
         balanceService: BalanceServiceAPI = resolve(tag: BitcoinChainCoin.bitcoinCash),
         bridge: BitcoinCashWalletBridgeAPI = resolve()) {
        self.xPub = xPub
        self.id = xPub.address
        self.label = label ?? CryptoCurrency.bitcoinCash.defaultWalletName
        self.isDefault = isDefault
        self.hdAccountIndex = hdAccountIndex
        self.fiatPriceService = fiatPriceService
        self.balanceService = balanceService
        self.bridge = bridge
    }

    func can(perform action: AssetAction) -> Single<Bool> {
        switch action {
        case .receive,
             .send,
             .viewActivity:
            return .just(true)
        case .deposit,
             .sell,
             .withdraw:
            return .just(false)
        case .swap:
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

    func updateLabel(_ newLabel: String) -> Completable {
        bridge.update(accountIndex: hdAccountIndex, label: newLabel)
    }
}
