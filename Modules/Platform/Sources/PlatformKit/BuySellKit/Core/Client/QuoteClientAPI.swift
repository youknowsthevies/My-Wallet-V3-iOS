// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import MoneyKit
import NabuNetworkError

public enum Profile: String {
    case simpleBuy = "SIMPLEBUY"
    case simpleTrade = "SIMPLETRADE"
    case swapFromUserKey = "SWAP_FROM_USERKEY"
    case swapInternal = "SWAP_INTERNAL"
    case swapOnChain = "SWAP_ON_CHAIN"
}

protocol QuoteClientAPI: AnyObject {

    /// Get a quote from a simple-buy order. In the future, it will support all sorts of order (buy, sell, swap)
    /// Parameters:
    ///   - profile: The profile for the quote
    ///   - fiatCurrency: The fiat currency representation
    ///   - cryptoCurrency: The crypto currency representation
    ///   - amount: The fiat value represented in minor units
    ///   - paymentMethod: The payment method payload type used
    ///   - paymentMethodId: The payment method Id for the quote
    func getQuote(
        for profile: Profile,
        from fiatCurrency: FiatCurrency,
        to cryptoCurrency: CryptoCurrency,
        amount: FiatValue,
        paymentMethod: PaymentMethodPayloadType?,
        paymentMethodId: String?
    ) -> AnyPublisher<QuoteResponse, NabuNetworkError>
}
