// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine

public enum ExchangeAccountRepositoryError: Error {
    case failedCheckLinkedExchange
    case failedToSyncAddresses
}

public protocol ExchangeAccountRepositoryAPI {
    var hasLinkedExchangeAccount: AnyPublisher<Bool, ExchangeAccountRepositoryError> { get }

    func syncDepositAddresses() -> AnyPublisher<Void, ExchangeAccountRepositoryError>
    func syncDepositAddressesIfLinked() -> AnyPublisher<Void, ExchangeAccountRepositoryError>
}
