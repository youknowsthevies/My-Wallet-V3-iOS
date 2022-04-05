// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import NetworkError

public protocol WatchlistRepositoryAPI {

    func addToWatchlist(
        _ assetCode: String
    ) -> AnyPublisher<Void, NetworkError>

    func removeFromWatchlist(
        _ assetCode: String
    ) -> AnyPublisher<Void, NetworkError>

    func getWatchlist() -> AnyPublisher<Set<String>, NetworkError>
}
