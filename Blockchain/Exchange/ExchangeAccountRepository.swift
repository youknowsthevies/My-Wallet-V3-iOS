// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BitcoinCashKit
import BitcoinKit
import Combine
import DIKit
import NetworkKit
import PlatformKit
import RxSwift
import SettingsKit

protocol ExchangeAccountRepositoryAPI {
    var hasLinkedExchangeAccount: Single<Bool> { get }
    func syncDepositAddresses() -> Completable
    func syncDepositAddressesIfLinked() -> Completable
    func syncDepositAddressesIfLinkedPublisher() -> AnyPublisher<Void, Error>
}

enum ExchangeLinkingAPIError: Error {
    case noLinkID
    case `unknown`
}

final class ExchangeAccountRepository: ExchangeAccountRepositoryAPI {

    private let blockchainRepository: BlockchainDataRepository
    private let clientAPI: ExchangeClientAPI
    private let accountRepository: AssetAccountRepositoryAPI

    init(blockchainRepository: BlockchainDataRepository = BlockchainDataRepository.shared,
         client: ExchangeClientAPI = resolve(),
         accountRepository: AssetAccountRepositoryAPI = AssetAccountRepository.shared) {
        self.blockchainRepository = blockchainRepository
        self.clientAPI = client
        self.accountRepository = accountRepository
    }

    var hasLinkedExchangeAccount: Single<Bool> {
        blockchainRepository
            .fetchNabuUser()
            .flatMap(weak: self, { (_, user) -> Single<Bool> in
                Single.just(user.hasLinkedExchangeAccount)
        })
    }

    func syncDepositAddressesIfLinked() -> Completable {
        hasLinkedExchangeAccount.flatMapCompletable(weak: self, { (self, linked) -> Completable in
            if linked {
                return self.syncDepositAddresses()
            } else {
                return Completable.empty()
            }
        })
    }

    func syncDepositAddressesIfLinkedPublisher() -> AnyPublisher<Void, Error> {
        syncDepositAddressesIfLinked()
            .asPublisher()
            .mapToVoid()
    }

    func syncDepositAddresses() -> Completable {
        accountRepository.accounts
            .flatMapCompletable(weak: self) { (self, accounts) -> Completable in
                let addresses = accounts.map { $0.address }
                return self.clientAPI.syncDepositAddress(accounts: addresses)
            }
    }
}
