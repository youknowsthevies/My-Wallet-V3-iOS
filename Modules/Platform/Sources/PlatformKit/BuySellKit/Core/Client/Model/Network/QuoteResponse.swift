// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import MoneyKit
import ToolKit

struct QuoteResponse: Decodable {
    struct FeeDetails: Decodable {
        enum FeeFlag: String, Decodable {
            case newUserWaiver = "NEW_USER_WAIVER"
        }

        let feeWithoutPromo: String
        let fee: String
        let feeFlags: [FeeFlag]
    }

    struct SettlementDetails: Decodable {
        enum AvailabilityType: String, Decodable {
            case instant = "INSTANT"
            case regular = "REGULAR"
            case unavailable = "UNAVAILABLE"
        }

        let availability: AvailabilityType
    }

    let quoteId: String
    let price: Double
    let feeDetails: FeeDetails
    let settlementDetails: SettlementDetails
}

public struct Quote {

    // MARK: - Types

    enum SetupError: Error {
        case feeParsing
    }

    // MARK: - Properties

    public let fee: FiatValue
    public let rate: FiatValue
    public let estimatedCryptoAmount: CryptoValue
    public let estimatedFiatAmount: FiatValue

    private let dateFormatter = DateFormatter.sessionDateFormat

    // MARK: - Setup

    init(
        to cryptoCurrency: CryptoCurrency,
        amount: FiatValue,
        response: QuoteResponse
    ) throws {
        guard let feeRateMinor = Decimal(string: response.feeDetails.fee) else {
            throw SetupError.feeParsing
        }
        let majorEstimatedAmount: Decimal = amount.amount.decimalDivision(divisor: BigInt(response.price))
        // Decimal string interpolation always uses '.' (full stop) as decimal separator, because of that we will use US locale.
        estimatedCryptoAmount = CryptoValue.create(major: majorEstimatedAmount, currency: cryptoCurrency)
        let feeAmountMinor = feeRateMinor * estimatedCryptoAmount.displayMajorValue
        // Decimal string interpolation always uses '.' (full stop) as decimal separator, because of that we will use US locale.
        fee = FiatValue.create(minor: feeAmountMinor, currency: amount.currency)
        rate = FiatValue.create(minor: BigInt(response.price), currency: amount.currency)
        estimatedFiatAmount = estimatedCryptoAmount.convertToFiatValue(exchangeRate: rate)
    }
}
