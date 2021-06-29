// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import RxSwift
import PlatformKit
import TransactionKit

final class BitPayRepository: BitPayRepositoryAPI {

    private enum Constants {
        static let forMerchant = "for merchant "
    }

    // MARK: - Properties

    private let client: BitPayClientAPI

    // MARK: - Setup

    init(client: BitPayClientAPI = resolve()) {
        self.client = client
    }

    // MARK: - BitPayServiceAPI

    func getBitPayPaymentRequest(
        invoiceId: String,
        currency: CryptoCurrency
    ) -> Single<BitPayInvoiceTarget> {
        client
            .bitpayPaymentRequest(invoiceId: invoiceId, currency: currency)
            .map { request -> BitPayInvoiceTarget in
                BitPayInvoiceTarget(
                    asset: currency,
                    amount: .create(minor: request.outputs[0].amount, currency: currency),
                    invoiceId: invoiceId,
                    merchant: request.memo
                        .components(separatedBy: Constants.forMerchant)
                        .last ?? "",
                    address: request.outputs[0].address,
                    expires: request.expires
                )
            }
            .eraseToAnyPublisher()
            .asObservable()
            .asSingle()
    }

    func submitBitPayPayment(
        invoiceId: String,
        currency: CryptoCurrency,
        transactionHex: String,
        transactionSize: Int
    ) -> Single<BitPayMemo> {
        client
            .postPayment(
                invoiceId: invoiceId,
                currency: currency,
                transactionHex: transactionHex,
                transactionSize: transactionSize
            )
            .map(BitPayMemo.init)
            .eraseToAnyPublisher()
            .asObservable()
            .asSingle()
    }

    func verifySignedTransaction(
        invoiceId: String,
        currency: CryptoCurrency,
        transactionHex: String,
        transactionSize: Int
    ) -> Completable {
        client
            .verifySignedTransaction(
                invoiceId: invoiceId,
                currency: currency,
                transactionHex: transactionHex,
                transactionSize: transactionSize
            )
            .asObservable()
            .ignoreElements()
    }
}
