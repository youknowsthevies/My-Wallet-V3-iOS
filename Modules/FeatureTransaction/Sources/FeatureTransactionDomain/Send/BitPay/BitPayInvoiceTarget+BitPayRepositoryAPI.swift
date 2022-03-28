// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import MoneyKit
import PlatformKit
import ToolKit

public enum BitPayError: Error {
    case invalidBitPayURL
    case invoiceFetchError(Error)
    case missingInvoiceID
}

extension BitPayInvoiceTarget {

    // MARK: - Enums

    private enum Prefix {
        static let bitpay = "bitpay.com"
        static let bitcoin = "bitcoin:?r="
        static let bitcoinCash = "bitcoincash:?r="
    }

    private static let bitpayRepository: BitPayRepositoryAPI = resolve()

    // MARK: - Public Factory

    public static func isBitcoin(_ data: String) -> Bool {
        data.contains(Prefix.bitcoin)
    }

    public static func isBitcoinCash(_ data: String) -> Bool {
        data.contains(Prefix.bitcoinCash)
    }

    public static func isSupportedAsset(_ asset: CryptoCurrency) -> Bool {
        asset.supportsBitPay
    }

    public static func isBitPay(_ data: String) -> Bool {
        data.contains(Prefix.bitpay)
    }

    public static func make(
        from data: String,
        asset: CryptoCurrency
    ) -> AnyPublisher<BitPayInvoiceTarget, BitPayError> {
        guard isBitPay(data) else {
            return .failure(.invalidBitPayURL)
        }
        guard isSupportedAsset(asset) else {
            return .failure(.invalidBitPayURL)
        }
        return invoiceId(from: data)
            .flatMap { invoiceId in
                BitPayInvoiceTarget.bitpayRepository
                    .getBitPayPaymentRequest(
                        invoiceId: invoiceId,
                        currency: asset
                    )
                    .mapError(BitPayError.invoiceFetchError)
            }
            .eraseToAnyPublisher()
    }

    // MARK: - Private Functions

    private static func invoiceId(from data: String) -> AnyPublisher<String, BitPayError> {
        let payload = data
            .replacingOccurrences(of: Prefix.bitcoin, with: "")
            .replacingOccurrences(of: Prefix.bitcoinCash, with: "")
        guard let url = URL(string: payload) else {
            return .failure(.missingInvoiceID)
        }
        return .just(url.lastPathComponent)
    }
}
