// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import MoneyKit
import ToolKit

struct QuoteResponse: Decodable {
    let time: String
    let rate: String
    let rateWithoutFee: String
    /* the fee value is more of a feeRate (ie it is the fee per 1 unit of crypto) to get the actual
     "fee" you'll need to multiply by amount of crypto
     */
    let fee: String
}

public struct Quote {

    // MARK: - Types

    enum SetupError: Error {
        case dateFormatting
        case rateParsing
        case feeParsing
    }

    // MARK: - Properties

    public let time: Date
    public let fee: FiatValue
    public let rate: FiatValue
    public let estimatedCryptoAmount: CryptoValue
    public let estimatedFiatAmount: FiatValue

    private let dateFormatter = DateFormatter.sessionDateFormat

    // MARK: - Setup

    init(to cryptoCurrency: CryptoCurrency, amount: FiatValue, response: QuoteResponse) throws {
        guard let time = dateFormatter.date(from: response.time) else {
            throw SetupError.dateFormatting
        }
        guard let rate = BigInt(response.rate) else {
            throw SetupError.rateParsing
        }
        guard let feeRateMinor = Decimal(string: response.fee) else {
            throw SetupError.feeParsing
        }
        let majorEstimatedAmount: Decimal = amount.amount.decimalDivision(divisor: rate)
        // Decimal string interpolation always uses '.' (full stop) as decimal separator, because of that we will use US locale.
        estimatedCryptoAmount = CryptoValue.create(major: majorEstimatedAmount, currency: cryptoCurrency)
        let feeAmountMinor = feeRateMinor * estimatedCryptoAmount.displayMajorValue
        // Decimal string interpolation always uses '.' (full stop) as decimal separator, because of that we will use US locale.
        fee = FiatValue.create(minor: feeAmountMinor, currency: amount.currency)
        self.time = time
        self.rate = FiatValue.create(minor: rate, currency: amount.currency)
        estimatedFiatAmount = estimatedCryptoAmount.convertToFiatValue(exchangeRate: self.rate)
    }
}
