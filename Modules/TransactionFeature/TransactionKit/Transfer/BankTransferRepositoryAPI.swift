// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformKit
import RxSwift

public protocol BankTransferRepositoryAPI {

    func startBankTransfer(id: String, amount: MoneyValue) -> Single<BankTranferPayment>
}
