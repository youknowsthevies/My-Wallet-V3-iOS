//
//  SimpleBuyQuoteResponse.swift
//  PlatformKit
//
//  Created by Daniel Huri on 06/02/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import BigInt

public struct SimpleBuyQuoteResponse: Decodable {
    let time: String
    let rate: String
    let rateWithoutFee: String
    /* the fee value is more of a feeRate (ie it is the fee per 1 unit of crypto) to get the actual
     "fee" you'll need to multiply by amount of crypto
     */
    let fee: String
}

public struct SimpleBuyQuote {

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
    public let estimatedAmount: CryptoValue

    private let dateFormatter = DateFormatter.sessionDateFormat

    // MARK: - Setup

    init(to cryptoCurrency: CryptoCurrency, amount: FiatValue, response: SimpleBuyQuoteResponse) throws {
        guard let time = dateFormatter.date(from: response.time) else {
            throw SetupError.dateFormatting
        }
        guard let rate = BigInt(response.rate) else {
            throw SetupError.rateParsing
        }
        guard let feeRate = Decimal(string: response.fee) else {
            throw SetupError.feeParsing
        }
        let majorAmount = amount.minorAmount.decimalDivision(divisor: rate)
        guard let estimatedAmount = CryptoValue.createFromMajorValue(string: "\(majorAmount)", assetType: cryptoCurrency)
            else { throw SetupError.createFromMajorValue }
        self.estimatedAmount = estimatedAmount
        let feeAmount = feeRate * estimatedAmount.majorValue
        self.fee = FiatValue(minor: "\(feeAmount)", currency: amount.currency)
        self.time = time
    }
}
