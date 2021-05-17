// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit

struct OrderQuoteResponse: Decodable {
    let identifier: String
    let product: Product
    let pair: OrderPair
    let quote: OrderQuote

    /// `MoneyValue` in the `pair.destinationCurrencyType`
    let networkFee: MoneyValue
    let staticFee: MoneyValue
    let sampleDepositAddress: String
    let expiresAt: Date
    let createdAt: Date
    let updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case pair
        case product
        case expiresAt
        case createdAt
        case updatedAt
        case sampleDepositAddress
        case networkFee
        case staticFee
        case quote
    }

    init(identifier: String,
         product: Product = .brokerage,
         pair: OrderPair,
         quote: OrderQuote,
         networkFee: MoneyValue,
         staticFee: MoneyValue,
         sampleDepositAddress: String,
         expiresAt: Date,
         createdAt: Date,
         updatedAt: Date) {
        self.identifier = identifier
        self.product = product
        self.pair = pair
        self.quote = quote
        self.networkFee = networkFee
        self.staticFee = staticFee
        self.sampleDepositAddress = sampleDepositAddress
        self.expiresAt = expiresAt
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let createdAt = try values.decode(String.self, forKey: .createdAt)
        let expiresAt = try values.decode(String.self, forKey: .expiresAt)
        let updatedAt = try values.decode(String.self, forKey: .updatedAt)

        identifier = try values.decode(String.self, forKey: .identifier)
        pair = try OrderPair(string: try values.decode(String.self, forKey: .pair))
        product = try values.decode(Product.self, forKey: .product)
        self.createdAt = try OrderQuoteResponse.date(
            from: createdAt,
            container: values
        )
        self.expiresAt = try OrderQuoteResponse.date(
            from: expiresAt,
            container: values
        )
        self.updatedAt = try OrderQuoteResponse.date(
            from: updatedAt,
            container: values
        )
        self.sampleDepositAddress = try values.decode(String.self, forKey: .sampleDepositAddress)
        let networkFeeValue = try values.decode(String.self, forKey: .networkFee)
        let staticFeeValue = try values.decode(String.self, forKey: .staticFee)
        let zeroDestination = MoneyValue.zero(currency: pair.destinationCurrencyType)
        networkFee = MoneyValue.create(minor: networkFeeValue, currency: pair.destinationCurrencyType) ?? zeroDestination
        staticFee = MoneyValue.create(minor: staticFeeValue, currency: pair.destinationCurrencyType) ?? zeroDestination
        quote = try values.decode(OrderQuote.self, forKey: .quote)
    }
}

private extension OrderQuoteResponse {
    static func date(from stringValue: String,
                     container: KeyedDecodingContainer<CodingKeys>) throws -> Date {
        let formatter = DateFormatter.sessionDateFormat
        if let value = formatter.date(from: stringValue) {
            return value
        } else {
            throw DecodingError.dataCorruptedError(
                forKey: .createdAt,
                in: container,
                debugDescription: "Date string does not match format expected by formatter."
            )
        }
    }
}
