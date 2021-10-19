// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import ToolKit

public protocol NabuUserServiceAPI: AnyObject {
    var user: AnyPublisher<NabuUser, Never> { get }

    func fetchUser() -> AnyPublisher<NabuUser, Never>
}

final class NabuUserService: NabuUserServiceAPI {

    // MARK: - Types

    private struct Key: Hashable {}

    // MARK: - Exposed Properties

    var user: AnyPublisher<NabuUser, Never> {
        cachedValue
            .get(key: Key())
            .ignoreFailure()
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
                            DispatchQueue.main.async {
                                siftService.set(userId: nabuUser.identifier)
                            }
                        }
                    )
                    .eraseError()
            }
        )
    }

    func fetchUser() -> AnyPublisher<NabuUser, Never> {
        cachedValue
            .get(key: Key(), forceFetch: true)
            .ignoreFailure()
    }
}
