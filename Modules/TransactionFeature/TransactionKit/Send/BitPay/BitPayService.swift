// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformKit
import RxSwift
import ToolKit

protocol BitPayServiceAPI {
    func getBitPayPaymentRequest(invoiceID: String, currency: CryptoCurrency) -> Single<BitpayPaymentRequest>
    func submitBitPayPayment(invoiceID: String, currency: CryptoCurrency, transactionHex: String, transactionSize: Int) -> Single<BitPayMemo>
    func verifySignedTransaction(invoiceID: String, currency: CryptoCurrency, transactionHex: String, transactionSize: Int) -> Completable
}

final class BitPayService: BitPayServiceAPI {

    // MARK: - Properties

    private let client: BitPayClientAPI

    // MARK: - Setup

    init(client: BitPayClientAPI = resolve()) {
        self.client = client
    }

    // MARK: - BitPayServiceAPI

    func getBitPayPaymentRequest(invoiceID: String, currency: CryptoCurrency) -> Single<BitpayPaymentRequest> {
        client
            .bitpayPaymentRequest(invoiceID: invoiceID, currency: currency)
    }

    func submitBitPayPayment(invoiceID: String, currency: CryptoCurrency, transactionHex: String, transactionSize: Int) -> Single<BitPayMemo> {
        client
            .postPayment(
                invoiceID: invoiceID,
                currency: currency,
                transactionHex: transactionHex,
                transactionSize: transactionSize
            )
    }

    func verifySignedTransaction(invoiceID: String, currency: CryptoCurrency, transactionHex: String, transactionSize: Int) -> Completable {
        client
            .verifySignedTransaction(
                invoiceID: invoiceID,
                currency: currency,
                transactionHex: transactionHex,
                transactionSize: transactionSize
            )
    }
}
