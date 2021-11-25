// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import MoneyKit
import NabuNetworkError

public enum Profile: String, Encodable {
    case simpleBuy = "SIMPLEBUY"
    case simpleTrade = "SIMPLETRADE"
    case swapFromUserKey = "SWAP_FROM_USERKEY"
    case swapInternal = "SWAP_INTERNAL"
    case swapOnChain = "SWAP_ON_CHAIN"
}

public struct QuoteRequest: Encodable {

    /// Profile for the quote
    let profile: String

    /// The fiat currency representation
    let inputCurrency: String

    /// The crypto currency representation
    let outputCurrency: String

    /// The fiat value represented in minor units
    let inputValue: String

    /// The payment method payload type used
    let paymentMethod: String?

    /// The payment method Id for the quote
    let paymentMethodId: String?
}

protocol QuoteClientAPI: AnyObject {

    /// Get a quote from a simple-buy order. In the future, it will support all sorts of order (buy, sell, swap)
    func getQuote(
        for profile: Profile,
        from fiatCurrency: FiatCurrency,
        to cryptoCurrency: CryptoCurrency,
        amount: FiatValue,
        paymentMethod: PaymentMethodPayloadType?,
        paymentMethodId: String?
    ) -> AnyPublisher<QuoteResponse, NabuNetworkError>
}
