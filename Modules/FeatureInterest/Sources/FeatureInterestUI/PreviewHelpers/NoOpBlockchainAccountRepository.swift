// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import PlatformKit

final class NoOpBlockchainAccountRepository: BlockchainAccountRepositoryAPI {
    func accountsWithCurrencyType(
        _ currency: CurrencyType
    ) -> AnyPublisher<[BlockchainAccount], BlockchainAccounRepositoryError> {
        Deferred {
            Future { _ in
            }
        }
        .eraseToAnyPublisher()
    }

    func accountsWithSingleAccountType(
        _ accountType: SingleAccountType
    ) -> AnyPublisher<[BlockchainAccount], BlockchainAccounRepositoryError> {
        Deferred {
            Future { _ in
            }
        }
        .eraseToAnyPublisher()
    }

    func accountsWithCurrencyType(
        _ currency: CurrencyType,
        accountType: SingleAccountType
    ) -> AnyPublisher<[BlockchainAccount], BlockchainAccounRepositoryError> {
        Deferred {
            Future { _ in
            }
        }
        .eraseToAnyPublisher()
    }

    func accountWithCurrencyType(
        _ currency: CurrencyType,
        accountType: SingleAccountType
    ) -> AnyPublisher<BlockchainAccount, BlockchainAccounRepositoryError> {
        Deferred {
            Future { _ in
            }
        }
        .eraseToAnyPublisher()
    }
}
