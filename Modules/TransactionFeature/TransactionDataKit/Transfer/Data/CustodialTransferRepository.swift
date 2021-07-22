// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformKit
import RxSwift
import TransactionKit

final class CustodialTransferRepository: CustodialTransferRepositoryAPI {

    // MARK: - Properties

    private let client: CustodialTransferClientAPI

    // MARK: - Setup

    init(client: CustodialTransferClientAPI = resolve()) {
        self.client = client
    }

    // MARK: - CustodialTransferServiceAPI

    func transfer(moneyValue: MoneyValue, destination: String, memo: String?) -> Single<CustodialWithdrawalIdentifier> {
        client
            .send(
                transferRequest: CustodialTransferRequest(
                    address: destinationAddress(with: destination, memo: memo),
                    moneyValue: moneyValue
                )
            )
            .map(\.identifier)
            .eraseToAnyPublisher()
            .asObservable()
            .asSingle()
    }

    func fees() -> Single<CustodialTransferFee> {
        client
            .custodialTransferFees()
            .map { response in
                CustodialTransferFee(
                    fee: response.fees,
                    minimumAmount: response.minAmounts
                )
            }
            .eraseToAnyPublisher()
            .asObservable()
            .asSingle()
    }

    private func destinationAddress(with destination: String, memo: String?) -> String {
        guard let memo = memo, !memo.isEmpty else {
            return destination
        }
        return destination + ":" + memo
    }
}
