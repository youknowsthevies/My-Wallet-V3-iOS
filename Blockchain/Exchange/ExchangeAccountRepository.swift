// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BitcoinCashKit
import BitcoinKit
import Combine
import DIKit
import FeatureSettingsDomain
import PlatformKit
import RxSwift

enum ExchangeLinkingAPIError: Error {
    case noLinkID
    case unknown
}

final class ExchangeAccountRepository: ExchangeAccountRepositoryAPI {

    private let nabuUserService: NabuUserServiceAPI
    private let client: ExchangeClientAPI
    private let coincore: CoincoreAPI

    init(
        nabuUserService: NabuUserServiceAPI = resolve(),
        client: ExchangeClientAPI = resolve(),
        coincore: CoincoreAPI = resolve()
    ) {
        self.nabuUserService = nabuUserService
        self.client = client
        self.coincore = coincore
    }

    var hasLinkedExchangeAccount: Single<Bool> {
        nabuUserService.user
            .map(\.hasLinkedExchangeAccount)
            .asSingle()
    }

    func syncDepositAddressesIfLinked() -> Completable {
        hasLinkedExchangeAccount
            .flatMapCompletable(weak: self) { (self, linked) -> Completable in
                if linked {
                    return self.syncDepositAddresses()
                } else {
                    return Completable.empty()
                }
            }
    }

    func syncDepositAddressesIfLinkedPublisher() -> AnyPublisher<Void, Error> {
        syncDepositAddressesIfLinked()
            .asPublisher()
            .mapToVoid()
    }

    func syncDepositAddresses() -> Completable {
        Single
            .just(coincore.cryptoAssets)
            .flatMap { cryptoAssets -> Single<[SingleAccount?]> in
                Single.zip(
                    cryptoAssets
                        .map { asset -> Single<SingleAccount?> in
                            asset.defaultAccount
                                .optional()
                                .replaceError(with: nil)
                                .eraseToAnyPublisher()
                                .asSingle()
                        }
                )
            }
            .map { accounts -> [SingleAccount] in
                accounts.compactMap { $0 }
            }
            .flatMap { accounts -> Single<[ReceiveAddress]> in
                Single.zip(accounts.map(\.receiveAddress))
            }
            .map { receiveAddresses -> [CryptoReceiveAddress] in
                receiveAddresses as? [CryptoReceiveAddress] ?? []
            }
            .flatMapCompletable { [client] receiveAddresses in
                client.syncDepositAddress(accounts: receiveAddresses)
                    .asObservable()
                    .ignoreElements()
            }
    }
}
