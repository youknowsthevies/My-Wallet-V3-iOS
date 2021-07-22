// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformKit
import RxSwift
import TransactionKit

final class FiatWithdrawRepository: FiatWithdrawRepositoryAPI {

    // MARK: - Properties

    private let client: BankTransferClientAPI

    // MARK: - Setup

    init(client: BankTransferClientAPI = resolve()) {
        self.client = client
    }

    // MARK: - BankTransferServiceAPI

    func createWithdrawOrder(id: String, amount: MoneyValue) -> Completable {
        client.createWithdrawOrder(id: id, amount: amount)
            .asObservable()
            .ignoreElements()
    }
}
