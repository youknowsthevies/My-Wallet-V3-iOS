// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine

public enum ExchangeAccountRepositoryError: Error {
    case failedCheckLinkedExchange
    case failedToSyncAddresses
}

public protocol ExchangeAccountRepositoryAPI {
    func syncDepositAddressesIfLinked() -> AnyPublisher<Void, ExchangeAccountRepositoryError>
}
