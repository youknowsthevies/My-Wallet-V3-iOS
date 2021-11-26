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
    let quoteMarginPercent: Double
    let quoteCreatedAt: String
    let quoteExpiresAt: String
    let price: String
    let networkFee: String?
    let staticFee: String?
    let feeDetails: FeeDetails
    let settlementDetails: SettlementDetails
    let sampleDepositAddress: String?
}

public struct Quote {

    // MARK: - Types

    enum SetupError: Error {
        case dateFormatting
        case priceParsing
        case feeParsing
    }

    // MARK: - Properties

    public let quoteId: String
    public let quoteCreatedAt: Date
    public let quoteExpiresAt: Date
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
        quoteId = response.quoteId
        guard let quoteCreatedDate = dateFormatter.date(from: response.quoteCreatedAt),
              let quoteExpiresDate = dateFormatter.date(from: response.quoteExpiresAt)
        else {
            throw SetupError.dateFormatting
        }
        quoteCreatedAt = quoteCreatedDate
        quoteExpiresAt = quoteExpiresDate
        guard let priceMinor = Decimal(string: response.price),
              let priceMinorBigInt = BigInt(response.price)
        else {
            throw SetupError.priceParsing
        }
        rate = FiatValue.create(minor: priceMinor, currency: amount.currency)
        let majorEstimatedAmount: Decimal = amount.amount.decimalDivision(divisor: priceMinorBigInt)
        // Decimal string interpolation always uses '.' (full stop) as decimal separator, because of that we will use US locale.
        estimatedCryptoAmount = CryptoValue.create(major: majorEstimatedAmount, currency: cryptoCurrency)
        guard let feeRateMinor = Decimal(string: response.feeDetails.fee) else {
            throw SetupError.feeParsing
        }
        let feeAmountMinor = feeRateMinor * estimatedCryptoAmount.displayMajorValue
        // Decimal string interpolation always uses '.' (full stop) as decimal separator, because of that we will use US locale.
        fee = FiatValue.create(minor: feeAmountMinor, currency: amount.currency)
        estimatedFiatAmount = estimatedCryptoAmount.convertToFiatValue(exchangeRate: rate)
    }
}
