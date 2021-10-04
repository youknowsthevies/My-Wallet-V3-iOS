// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import RxSwift

public protocol ExchangeAccountRepositoryAPI {
    var hasLinkedExchangeAccount: Single<Bool> { get }

    func syncDepositAddresses() -> Completable
    func syncDepositAddressesIfLinked() -> Completable
    func syncDepositAddressesIfLinkedPublisher() -> AnyPublisher<Void, Error>
}
