//
//  ClientMocks.swift
//  PlatformKitTests
//
//  Created by Daniel Huri on 14/02/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

@testable import PlatformKit

extension SimpleBuyClient {

    static func mockPaymentAccountResponse(for currency: FiatCurrency = .GBP) -> SimpleBuyPaymentAccountResponse {
        let mockAgent = SimpleBuyPaymentAccountResponse.Agent(
            account: "123456987",
            address: "4250 Executive Square, La Jolla, California, 92037",
            code: "LHVBEE22",
            country: "Estonia",
            name: "LHV",
            recipient: "Fred Wilson",
            routingNumber: "123456987"
        )
        return SimpleBuyPaymentAccountResponse(
            id: "12-34-56-78",
            address: "4250 Executive Square, La Jolla, California, 92037",
            agent: mockAgent,
            currency: currency,
            state: .pending
        )
    }

    static func mockQuote(for action: SimpleBuyOrder.Action,
                          to cryptoCurrency: CryptoCurrency,
                          amount: FiatValue) -> SimpleBuyQuoteResponse {
        return SimpleBuyQuoteResponse(time: "2020-01-15T22:09:45.600Z")
    }

    static func mockOrderCreation(order: SimpleBuyOrderCreationData.Request) -> SimpleBuyOrderCreationData.Response {
        return .init(
            id: UUID().uuidString,
            inputCurrency: order.input.symbol,
            inputQuantity: order.input.amount,
            outputCurrency: order.output.symbol,
            outputQuantity: "100000",
            state: "PENDING_DEPOSIT",
            insertedAt: "2020-01-01T12:20:42.849Z",
            updatedAt: "2020-01-01T12:20:42.849Z",
            expiresAt: "2020-01-01T12:20:42.849Z"
        )
    }

    static func mockSuggestedAmounts(currency: FiatCurrency) -> SimpleBuySuggestedAmountsResponse {
        return SimpleBuySuggestedAmountsResponse(
            rawResponse: [[currency.code : ["1000", "2000"]]]
        )
    }

    static var mockOrdersDetails: [SimpleBuyOrderDetailsResponse] {
        [
            SimpleBuyOrderDetailsResponse(
                id: "111111-aaaaaaaa-111111",
                inputQuantity: "10000",
                inputCurrency: FiatCurrency.GBP.code,
                outputCurrency: CryptoCurrency.ethereum.code,
                state: SimpleBuyOrderDetails.State.pendingDeposit.rawValue
            )
        ]
    }

    static func mockSupportedPairs(currency: FiatCurrency) -> SimpleBuySupportedPairsResponse {
        SimpleBuySupportedPairsResponse(
            pairs: [
                SimpleBuySupportedPairsResponse.Pair(
                    pair: "BTC-\(currency.code)",
                    buyMin: "1000",
                    buyMax: "100000"
                ),
                SimpleBuySupportedPairsResponse.Pair(
                    pair: "BTC-\(currency.code)",
                    buyMin: "1000",
                    buyMax: "100000"
                ),
                SimpleBuySupportedPairsResponse.Pair(
                    pair: "BCH-\(currency.code)",
                    buyMin: "1000",
                    buyMax: "100000"
                ),
                SimpleBuySupportedPairsResponse.Pair(
                    pair: "ETH-\(currency.code)",
                    buyMin: "100",
                    buyMax: "10000"
                )
            ]
        )
    }
}
