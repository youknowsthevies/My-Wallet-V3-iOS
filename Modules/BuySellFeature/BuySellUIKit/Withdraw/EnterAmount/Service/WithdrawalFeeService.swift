// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BuySellKit
import DIKit
import PlatformKit
import RxSwift

final class WithdrawalFeeService {

    private let withdrawalService: WithdrawalServiceAPI

    init(withdrawalService: WithdrawalServiceAPI = resolve()) {
        self.withdrawalService = withdrawalService
    }

    func withdrawCheckoutData(data: ValidatedData) -> Single<WithdrawalCheckoutData> {
        withdrawalService.withdrawalFee(for: data.currency)
            .map { fee -> WithdrawalCheckoutData in
                WithdrawalCheckoutData(currency: data.currency,
                                       beneficiary: data.beneficiary,
                                       amount: data.amount,
                                       fee: fee)
            }
    }
}
