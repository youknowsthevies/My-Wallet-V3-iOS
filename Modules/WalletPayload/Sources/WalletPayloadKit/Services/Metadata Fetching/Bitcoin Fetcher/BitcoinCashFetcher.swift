// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import Foundation
import MetadataKit
import ToolKit

/// Types adopting `BitcoinCashEntryFetcherAPI` should be able to provide entries for Bitcoin and BitcoinCash assets
public protocol BitcoinCashEntryFetcherAPI {
    /// Fetches a `BitcoinCashEntry` from Wallet metadata
    func fetchBitcoinCash() -> AnyPublisher<BitcoinCashEntry, WalletAssetFetchError>
}

final class BitcoinCashEntryFetcher: BitcoinCashEntryFetcherAPI {

    private let walletHolder: WalletHolderAPI
    private let metadataEntryService: WalletMetadataEntryServiceAPI

    init(
        walletHolder: WalletHolderAPI,
        metadataEntryService: WalletMetadataEntryServiceAPI
    ) {
        self.walletHolder = walletHolder
        self.metadataEntryService = metadataEntryService
    }

    func fetchBitcoinCash() -> AnyPublisher<BitcoinCashEntry, WalletAssetFetchError> {
        metadataEntryService.fetchEntry(type: BitcoinCashEntryPayload.self)
            .flatMap { [fetchWallet] payload -> AnyPublisher<(BitcoinCashEntryPayload, Wallet), WalletAssetFetchError> in
                fetchWallet()
                    .map { (payload, $0) }
                    .eraseToAnyPublisher()
            }
            .map(BitcoinCashEntry.init(payload:wallet:))
            .eraseToAnyPublisher()
    }

    private func fetchWallet() -> AnyPublisher<Wallet, WalletAssetFetchError> {
        walletHolder.walletStatePublisher
            .flatMap { state -> AnyPublisher<Wallet, WalletAssetFetchError> in
                guard let wallet = state?.wallet else {
                    return .failure(.notInitialized)
                }
                return .just(wallet)
            }
            .eraseToAnyPublisher()
    }
}
