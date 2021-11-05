// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation

public final class NoOpWithdrawalLocksService: WithdrawalLocksServiceAPI {

    public var withdrawLocks: AnyPublisher<WithdrawalLocks, Never> = Empty().eraseToAnyPublisher()

    public init() {}
}
