// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import CombineExt
import DIKit
import RxSwift
import ToolKit

public protocol NabuUserServiceAPI: AnyObject {
    var user: Single<NabuUser> { get }

    var userPublisher: AnyPublisher<NabuUser, Never> { get }

    func fetchUser() -> Single<NabuUser>

    func fetchUserPublisher() -> AnyPublisher<NabuUser, Never>
}

final class NabuUserService: NabuUserServiceAPI {

    // MARK: - Types

    private struct Key: Hashable {}

    // MARK: - Exposed Properties

    var userPublisher: AnyPublisher<NabuUser, Never> {
        cachedValue
            .get(key: Key())
            .ignoreFailure()
    }

    var user: Single<NabuUser> {
        cachedValue
            .get(key: Key())
            .asSingle()
    }

    // MARK: - Properties

    private let client: KYCClientAPI
    private let siftService: SiftServiceAPI
    private let cachedValue: CachedValueNew<
        Key,
        NabuUser,
        Error
    >

    // MARK: - Setup

    init(
        client: KYCClientAPI = resolve(),
        siftService: SiftServiceAPI = resolve()
    ) {
        self.client = client
        self.siftService = siftService

        let cache: AnyCache<Key, NabuUser> = InMemoryCache(
            configuration: .onLoginLogout(),
            refreshControl: PerpetualCacheRefreshControl()
        ).eraseToAnyCache()

        cachedValue = CachedValueNew(
            cache: cache,
            fetch: { [client, siftService] _ in
                client
                    .fetchUser()
                    .handleEvents(
                        receiveOutput: { nabuUser in
                            siftService.set(userId: nabuUser.identifier)
                        }
                    )
                    .eraseError()
            }
        )
    }

    func fetchUserPublisher() -> AnyPublisher<NabuUser, Never> {
        cachedValue
            .get(key: Key(), forceFetch: true)
            .ignoreFailure()
    }

    func fetchUser() -> Single<NabuUser> {
        cachedValue
            .get(key: Key(), forceFetch: true)
            .asSingle()
    }
}
