// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import Combine
import DIKit
import FeatureWithdrawalLocksDomain
import Foundation
import NabuNetworkError

final class WithdrawalLocksRepository: WithdrawalLocksRepositoryAPI {

    private let client: WithdrawalLocksClientAPI
    private let moneyValueFormatter: MoneyValueFormatterAPI

    private let decodingDateFormatter = DateFormatter.sessionDateFormat
    private let encodingDateFormatter = DateFormatter.long

    init(
        client: WithdrawalLocksClientAPI = resolve(),
        moneyValueFormatter: MoneyValueFormatterAPI = resolve()
    ) {
        self.client = client
        self.moneyValueFormatter = moneyValueFormatter
    }

    func withdrawalLocks(
        currencyCode: String
    ) -> AnyPublisher<WithdrawalLocks, Never> {
        client.fetchWithdrawalLocks(currencyCode: currencyCode)
            .ignoreFailure()
            .map { [encodingDateFormatter, decodingDateFormatter, moneyValueFormatter] withdrawalLocks in
                WithdrawalLocks(
                    items: withdrawalLocks.locks.compactMap { lock in
                        guard let fromDate = decodingDateFormatter.date(from: lock.expiresAt) else {
                            return nil
                        }
                        return .init(
                            date: encodingDateFormatter.string(
                                from: fromDate
                            ),
                            amount: moneyValueFormatter.formatMoney(
                                amount: lock.amount.amount,
                                currency: lock.amount.currency
                            )
                        )
                    },
                    amount: moneyValueFormatter.formatMoney(
                        amount: withdrawalLocks.totalLocked.amount,
                        currency: withdrawalLocks.totalLocked.currency
                    )
                )
            }
            .eraseToAnyPublisher()
    }
}
