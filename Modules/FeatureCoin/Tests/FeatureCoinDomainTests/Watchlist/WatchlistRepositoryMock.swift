// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import FeatureCoinDomain
import Foundation
import NetworkError

final class WatchlistRepositoryMock: WatchlistRepositoryAPI {
    struct RecordedInvocations {
        var addToWatchlist: [String] = []
        var removeFromWatchlist: [String] = []
        var getWatchlist: [Void] = []
    }

    struct StubbedResults {
        var addToWatchlist: AnyPublisher<Void, NetworkError> = .empty()
        var removeFromWatchlist: AnyPublisher<Void, NetworkError> = .empty()
        var getWatchlist: AnyPublisher<Set<String>, NetworkError> = .empty()
    }

    private(set) var recordedInvocations = RecordedInvocations()
    var stubbedResults = StubbedResults()

    func addToWatchlist(
        _ assetCode: String
    ) -> AnyPublisher<Void, NetworkError> {
        recordedInvocations.addToWatchlist.append(assetCode)
        return stubbedResults.addToWatchlist
    }

    func removeFromWatchlist(
        _ assetCode: String
    ) -> AnyPublisher<Void, NetworkError> {
        recordedInvocations.removeFromWatchlist.append(assetCode)
        return stubbedResults.removeFromWatchlist
    }

    func getWatchlist() -> AnyPublisher<Set<String>, NetworkError> {
        recordedInvocations.getWatchlist.append(())
        return stubbedResults.getWatchlist
    }
}
