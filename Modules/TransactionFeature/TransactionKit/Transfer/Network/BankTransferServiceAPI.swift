// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformKit
import RxSwift

protocol BankTransferServiceAPI {
    func startBankTransfer(id: String, amount: MoneyValue) -> Single<String>
}

final class BankTransferService: BankTransferServiceAPI {

    // MARK: - Properties

    private let client: BankTransferClientAPI

    // MARK: - Setup

    init(client: BankTransferClientAPI = resolve()) {
        self.client = client
    }

    // MARK: - BankTransferServiceAPI

    func startBankTransfer(id: String, amount: MoneyValue) -> Single<String> {
        client
            .startBankTransfer(id: id, amount: amount)
            .map(\.paymentId)
    }
}
