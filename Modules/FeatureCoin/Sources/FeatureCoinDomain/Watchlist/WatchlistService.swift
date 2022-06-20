// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Combine
import Foundation
import MoneyKit
import NetworkError

public class WatchlistService {

    private var cancellables = Set<AnyCancellable>()

    public init(
        base: CryptoCurrency,
        watchlistRepository: WatchlistRepositoryAPI,
        app: AppProtocol
    ) {
        let watchlistSubject: CurrentValueSubject<Set<String>?, NetworkError> = CurrentValueSubject([])

        watchlistRepository.getWatchlist()
            .sink(receiveValue: watchlistSubject.send(_:))
            .store(in: &cancellables)

        app.on(blockchain.ux.asset[base.code].watchlist.add)
            .flatMap { _ in
                watchlistRepository.addToWatchlist(base.code)
            }
            .withLatestFrom(watchlistSubject)
            .map { watchlist in
                watchlist?.union(Set([base.code]))
            }
            .sink(receiveValue: watchlistSubject.send(_:))
            .store(in: &cancellables)

        app.on(blockchain.ux.asset[base.code].watchlist.remove)
            .flatMap { _ in
                watchlistRepository.removeFromWatchlist(base.code)
            }
            .withLatestFrom(watchlistSubject)
            .map { watchlist in
                watchlist?.filter { $0 != base.code }
            }
            .sink(receiveValue: watchlistSubject.send(_:))
            .store(in: &cancellables)

        watchlistSubject
            .filter { $0 != nil }
            .map {
                $0?.contains(base.code) == true
            }
            .sink { isOn in
                app.post(value: isOn, of: blockchain.ux.asset[base.code].watchlist.is.on)
            }
            .store(in: &cancellables)
    }
}

// MARK: - Preview Helper

extension WatchlistService {

    public static var preview: WatchlistService {
        .init(
            base: .bitcoin,
            watchlistRepository: PreviewWatchlistRepository(
                .just(()),
                .just(()),
                .just(["BTC"])
            ),
            app: App.preview
        )
    }

    public static var previewEmpty: WatchlistService {
        .init(
            base: .bitcoin,
            watchlistRepository: PreviewWatchlistRepository(),
            app: App.preview
        )
    }
}
