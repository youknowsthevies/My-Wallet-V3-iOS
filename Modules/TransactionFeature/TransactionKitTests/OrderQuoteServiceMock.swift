//
//  OrderQuoteServiceMock.swift
//  TransactionKitTests
//
//  Created by Alex McGregor on 11/3/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxSwift
@testable import TransactionKit

final class OrderQuoteServiceMock: OrderQuoteServiceAPI {
    var latestQuote: Single<OrderQuoteResponse> {
        // swiftlint:disable:next force_try
        let response = try! JSONDecoder().decode(OrderQuoteResponse.self, from: btc_eth_quote_response)
        return .just(response)
    }
    
    func fetchQuote(direction: OrderDirection, sourceCurrencyType: CurrencyType, destinationCurrencyType: CurrencyType) -> Single<OrderQuoteResponse> {
        latestQuote
    }
    
    private let btc_eth_quote_response = Data("""
    {
      "id": "039267ab-de16-4093-8cdf-a7ea1c732dbd",
      "product": "BROKERAGE",
      "pair": "BTC-ETH",
      "quote": {
        "currencyPair": "BTC-ETH",
        "priceTiers": [
          {
            "volume": "286",
            "price": "34936084430000000000",
            "marginPrice": "34936084430000000000"
          },
          {
            "volume": "2862782",
            "price": "34931056570000000000",
            "marginPrice": "34931056570000000000"
          }
        ]
      },
      "networkFee": "0",
      "staticFee": "0",
      "sampleDepositAddress": "1BitcoinEaterAddressDontSendf59kuE",
      "expiresAt": "2021-01-01T12:01:59.000Z",
      "createdAt": "2020-12-31T23:59:59.000Z",
      "updatedAt": "2020-12-31T23:59:59.000Z"
    }
    """.utf8)
}

extension OrderQuoteResponse {
    static let btc_eth_quote_response: OrderQuoteResponse = .init(
        identifier: "",
        pair: OrderPair(rawValue: "BTC-ETH")!,
        quote: .btc_eth_quote,
        networkFee: .zero(currency: .crypto(.bitcoin)),
        staticFee: .zero(currency: .crypto(.bitcoin)),
        sampleDepositAddress: "",
        expiresAt: Date(),
        createdAt: Date(),
        updatedAt: Date()
    )
}

extension OrderPair {
    static let btc_eth = OrderPair(rawValue: "BTC-ETH")!
}

extension OrderQuote {
    static let btc_eth_quote: OrderQuote = .init(pair: .btc_eth, priceTiers: [])
}
