// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import Foundation
import MetadataKit
import ToolKit

/// Types adopting `BitcoinEntryFetcherAPI` should be able to provide entries for Bitcoin and BitcoinCash assets
public protocol BitcoinEntryFetcherAPI {
    /// Fetches a `BitcoinEntry` from Wallet metadata
    func fetchBitcoin() -> AnyPublisher<BitcoinEntry, WalletAssetFetchError>
}

final class BitcoinEntryFetcher: BitcoinEntryFetcherAPI {

    private let walletHolder: WalletHolderAPI
    private let metadataEntryService: WalletMetadataEntryServiceAPI

    init(
        walletHolder: WalletHolderAPI,
        metadataEntryService: WalletMetadataEntryServiceAPI
    ) {
        self.walletHolder = walletHolder
        self.metadataEntryService = metadataEntryService
    }

    func fetchBitcoin() -> AnyPublisher<BitcoinEntry, WalletAssetFetchError> {
        metadataEntryService.fetchEntry(type: BitcoinEntryPayload.self)
            .flatMap { [walletHolder] payload -> AnyPublisher<BitcoinEntry, WalletAssetFetchError> in
                fetchWallet(walletHolder: walletHolder)
                    .map { BitcoinEntry(payload: payload, wallet: $0) }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}

private func fetchWallet(
    walletHolder: WalletHolderAPI
) -> AnyPublisher<NativeWallet, WalletAssetFetchError> {
    walletHolder.walletStatePublisher
        .flatMap { state -> AnyPublisher<NativeWallet, WalletAssetFetchError> in
            guard let wallet = state?.wallet else {
                return .failure(.notInitialized)
            }
            return .just(wallet)
        }
        .eraseToAnyPublisher()
}
