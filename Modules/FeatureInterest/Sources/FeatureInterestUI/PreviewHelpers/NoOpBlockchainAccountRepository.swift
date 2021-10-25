// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import PlatformKit

final class NoOpBlockchainAccountRepository: BlockchainAccountRepositoryAPI {
    func accountsWithCurrencyType(
        _ currency: CurrencyType
    ) -> AnyPublisher<[BlockchainAccount], BlockchainAccounRepositoryError> {
        Empty().eraseToAnyPublisher()
    }

    func accountsWithSingleAccountType(
        _ accountType: SingleAccountType
    ) -> AnyPublisher<[BlockchainAccount], BlockchainAccounRepositoryError> {
        Empty().eraseToAnyPublisher()
    }

    func accountsWithCurrencyType(
        _ currency: CurrencyType,
        accountType: SingleAccountType
    ) -> AnyPublisher<[BlockchainAccount], BlockchainAccounRepositoryError> {
        Empty().eraseToAnyPublisher()
    }

    func accountWithCurrencyType(
        _ currency: CurrencyType,
        accountType: SingleAccountType
    ) -> AnyPublisher<BlockchainAccount, BlockchainAccounRepositoryError> {
        Empty().eraseToAnyPublisher()
    }
}
