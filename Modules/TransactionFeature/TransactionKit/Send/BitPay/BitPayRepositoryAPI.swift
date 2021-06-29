// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformKit
import RxSwift
import ToolKit

public protocol BitPayRepositoryAPI {

    func getBitPayPaymentRequest(
        invoiceId: String,
        currency: CryptoCurrency
    ) -> Single<BitPayInvoiceTarget>

    func submitBitPayPayment(
        invoiceId: String,
        currency: CryptoCurrency,
        transactionHex: String,
        transactionSize: Int
    ) -> Single<BitPayMemo>

    func verifySignedTransaction(
        invoiceId: String,
        currency: CryptoCurrency,
        transactionHex: String,
        transactionSize: Int
    ) -> Completable
}
