// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import Combine
import DIKit
import Foundation
import NabuNetworkError
import PlatformKit
import ToolKit

public protocol WithdrawalLocksRepositoryAPI {
    func withdrawLocks(
        currencyCode: String
    ) -> AnyPublisher<WithdrawalLocks, Never>
}

class WithdrawalLocksRepository: WithdrawalLocksRepositoryAPI {

    private let client: WithdrawalLocksClientAPI

    private let decodingDateFormatter = DateFormatter.sessionDateFormat
    private let encodingDateFormatter = DateFormatter.medium

    init(
        client: WithdrawalLocksClientAPI = resolve()
    ) {
        self.client = client
    }

    func withdrawLocks(
        currencyCode: String
    ) -> AnyPublisher<WithdrawalLocks, Never> {
        client.fetchWithdrawalLocks(currencyCode: currencyCode)
            .ignoreFailure()
            .map { [encodingDateFormatter, decodingDateFormatter] withdrawalLocks in
                WithdrawalLocks(
                    items: withdrawalLocks.locks.map { lock in
                        .init(
                            date: encodingDateFormatter.string(
                                from: decodingDateFormatter.date(from: lock.expiresAt)!
                            ),
                            amount: FiatValue(
                                amount: BigInt(stringLiteral: lock.amount.amount),
                                currency: FiatCurrency(code: lock.amount.currency)!
                            ).displayString
                        )
                    },
                    amount: FiatValue(
                        amount: BigInt(stringLiteral: withdrawalLocks.totalLocked.amount),
                        currency: FiatCurrency(code: withdrawalLocks.totalLocked.currency)!
                    ).displayString
                )
            }
            .eraseToAnyPublisher()
    }
}
