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
            .flatMap { [fetchWallet] payload -> AnyPublisher<BitcoinCashEntry, WalletAssetFetchError> in
                fetchWallet()
                    .map { BitcoinCashEntry(payload: payload, wallet: $0) }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    private func fetchWallet() -> AnyPublisher<NativeWallet, WalletAssetFetchError> {
        walletHolder.walletStatePublisher
            .flatMap { state -> AnyPublisher<NativeWallet, WalletAssetFetchError> in
                guard let wallet = state?.wallet else {
                    return .failure(.notInitialized)
                }
                return .just(wallet)
            }
            .eraseToAnyPublisher()
    }
}
