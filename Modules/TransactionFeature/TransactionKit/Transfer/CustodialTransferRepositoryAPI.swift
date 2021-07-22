// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import RxSwift

public protocol CustodialTransferRepositoryAPI {

    // MARK: - Types

    typealias CustodialWithdrawalIdentifier = String

    // MARK: - Methods

    func transfer(
        moneyValue: MoneyValue,
        destination: String,
        memo: String?
    ) -> Single<CustodialWithdrawalIdentifier>

    func fees() -> Single<CustodialTransferFee>
}
