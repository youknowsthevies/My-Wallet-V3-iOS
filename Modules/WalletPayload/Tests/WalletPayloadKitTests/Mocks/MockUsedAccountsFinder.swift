// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import WalletPayloadKit

import Combine
import Errors

class MockUsedAccountsFinder: UsedAccountsFinderAPI {

    var findUsedAccountResult: Result<Int, UsedAccountsFinderError> = .failure(
        .networkError(.unknown)
    )

    func findUsedAccounts(
        batch: UInt,
        xpubRetriever: @escaping XpubRetriever
    ) -> AnyPublisher<Int, UsedAccountsFinderError> {
        findUsedAccountResult
            .publisher
            .eraseToAnyPublisher()
    }
}
