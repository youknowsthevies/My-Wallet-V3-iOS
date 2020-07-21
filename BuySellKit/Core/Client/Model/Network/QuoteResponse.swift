//
//  QuoteResponse.swift
//  PlatformKit
//
//  Created by Daniel Huri on 06/02/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import BigInt
import PlatformKit

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
        case createFromMajorValue
        case dateFormatting
        case rateParsing
        case feeParsing
    }

    // MARK: - Properties

    public let time: Date
    public let fee: FiatValue
    public let rate: FiatValue
    public let estimatedAmount: CryptoValue

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
        let majorEstimatedAmount: Decimal = amount.minorAmount.decimalDivision(divisor: rate)
        /// Decimal string interpolation always uses '.' (full stop) as decimal separator, because of that we will use US locale.
        guard let estimatedAmount = CryptoValue.createFromMajorValue(string: "\(majorEstimatedAmount)", assetType: cryptoCurrency, locale: .US)
            else { throw SetupError.createFromMajorValue }
        self.estimatedAmount = estimatedAmount
        let feeAmountMinor = feeRateMinor * estimatedAmount.majorValue
        /// Decimal string interpolation always uses '.' (full stop) as decimal separator, because of that we will use US locale.
        self.fee = FiatValue(minor: "\(feeAmountMinor)", currency: amount.currencyType, locale: .US)
        self.time = time
        self.rate = FiatValue(minor: response.rate, currency: amount.currencyType)
    }
}

