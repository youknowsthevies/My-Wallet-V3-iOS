// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import RxSwift

@testable import Blockchain

class MockExchangeAccountRepository: ExchangeAccountRepositoryAPI {
   var hasLinkedExchangeAccount: Single<Bool> = .just(false)

   func syncDepositAddresses() -> Completable {
       .just(event: .completed)
   }

   func syncDepositAddressesIfLinked() -> Completable {
       .just(event: .completed)
   }

   func syncDepositAddressesIfLinkedPublisher() -> AnyPublisher<Void, Error> {
       .just(())
   }
}
