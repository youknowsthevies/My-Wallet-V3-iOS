// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import PlatformKit
import RxSwift

/// This is for transferring or sending custodial funds to
/// a non-custodial wallet
protocol CustodialTransferClientAPI {
    /// A `403` means an internal send is pending.
    /// A `409` means you have insufficient funds for the internal send.
    func send(transferRequest: CustodialTransferRequest) -> Single<CustodialTransferResponse>

    func custodialTransferFees() -> Single<CustodialTransferFeesResponse>
}

struct CustodialTransferFeesResponse: Decodable {
    private struct Value: Decodable {
        let symbol: String
        let minorValue: String
    }

    let minAmounts: [CurrencyType: MoneyValue]
    let fees: [CurrencyType: MoneyValue]

    enum CodingKeys: CodingKey {
        case minAmounts
        case fees
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let minAmounts = try container.decode([Value].self, forKey: .minAmounts)
        let fees = try container.decode([Value].self, forKey: .fees)
        self.minAmounts = minAmounts.reduce(into: [CurrencyType: MoneyValue]()) { (result, value) in
            guard let currency = try? CurrencyType(code: value.symbol) else {
                return
            }
            guard let amount = BigInt(value.minorValue) else {
                return
            }
            result[currency] = MoneyValue.init(amount: amount, currency: currency)
        }
        self.fees = fees.reduce(into: [CurrencyType: MoneyValue]()) { (result, value) in
            guard let currency = try? CurrencyType(code: value.symbol) else {
                return
            }
            guard let amount = BigInt(value.minorValue) else {
                return
            }
            result[currency] = MoneyValue.init(amount: amount, currency: currency)
        }
    }
}
