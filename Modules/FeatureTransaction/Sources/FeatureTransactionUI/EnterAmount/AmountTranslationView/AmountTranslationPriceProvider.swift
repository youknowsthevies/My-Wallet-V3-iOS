// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import MoneyKit
import PlatformKit
import PlatformUIKit
import RxSwift
import ToolKit

final class AmountTranslationPriceProvider: AmountTranslationPriceProviding {

    private let transactionModel: TransactionModel

    init(transactionModel: TransactionModel) {
        self.transactionModel = transactionModel
    }

    func pairFromFiatInput(
        cryptoCurrency: CryptoCurrency,
        fiatCurrency: FiatCurrency,
        amount: String
    ) -> Single<MoneyValuePair> {
        transactionModel
            .state
            .compactMap(\.amountExchangeRateForTradingUsingFiatAsInput)
            .map { exchangeRate -> MoneyValuePair in
                let amount = amount.isEmpty ? "0" : amount
                let moneyValue = MoneyValue.create(majorDisplay: amount, currency: fiatCurrency.currencyType)!
                return MoneyValuePair(base: moneyValue, exchangeRate: exchangeRate)
            }
            .take(1)
            .asSingle()
    }

    func pairFromCryptoInput(
        cryptoCurrency: CryptoCurrency,
        fiatCurrency: FiatCurrency,
        amount: String
    ) -> Single<MoneyValuePair> {
        transactionModel
            .state
            .compactMap(\.amountExchangeRateForTradingUsingCryptoAsInput)
            .map { exchangeRate -> MoneyValuePair in
                let amount = amount.isEmpty ? "0" : amount
                let moneyValue = MoneyValue.create(majorDisplay: amount, currency: cryptoCurrency.currencyType)!
                return MoneyValuePair(base: moneyValue, exchangeRate: exchangeRate)
            }
            .take(1)
            .asSingle()
    }
}

extension TransactionState {

    fileprivate var amountExchangeRateForTradingUsingFiatAsInput: MoneyValue? {
        let exchangeRate: MoneyValue?
        switch action {
        case .buy:
            // the input refers to the destination but needs to expressed in fiat, so the exchange rate must be fiat -> destination
            // source is always fiat for buy
            exchangeRate = exchangeRates?.sourceToDestinationTradingCurrencyRate
        default:
            // the input refers to the source account, so the exchange rate must be fiat -> source
            exchangeRate = exchangeRates?.fiatTradingCurrencyToSourceRate
        }
        return exchangeRate
    }

    fileprivate var amountExchangeRateForTradingUsingCryptoAsInput: MoneyValue? {
        let exchangeRate: MoneyValue?
        switch action {
        case .buy:
            // the input refers to the destination account and the input is in that account's currency.
            exchangeRate = exchangeRates?.destinationToFiatTradingCurrencyRate
        default:
            // the source may be in crypto or fiat, if source is fiat, the fiat -> fiat rate will be one, the crypto -> fiat rate otherwise.
            exchangeRate = exchangeRates?.sourceToFiatTradingCurrencyRate
        }
        return exchangeRate
    }
}
