// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import FeatureCoinDomain
import Foundation
import NabuNetworkError
import NetworkError

public struct WatchlistRepository: WatchlistRepositoryAPI {

    private let client: WatchlistClientAPI
    private let watchlistTagName = "Favourite"

    public init(_ client: WatchlistClientAPI) {
        self.client = client
    }

    public func addToWatchlist(
        _ assetCode: String
    ) -> AnyPublisher<Void, NetworkError> {
        client.addTags(.init(asset: assetCode, tags: [watchlistTagName]))
            .mapToVoid()
    }

    public func removeFromWatchlist(
        _ assetCode: String
    ) -> AnyPublisher<Void, NetworkError> {
        client.removeTags(.init(asset: assetCode, tags: [watchlistTagName]))
    }

    public func getWatchlist() -> AnyPublisher<Set<String>, NetworkError> {
        client.getTags()
            .map { taggedAssets -> [String] in
                taggedAssets.assets.filter { taggedAsset in
                    taggedAsset.tags.map(\.tag).contains(watchlistTagName)
                }
                .map(\.asset)
            }
            .map(Set.init)
            .eraseToAnyPublisher()
    }
}
