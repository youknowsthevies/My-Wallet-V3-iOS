// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import Foundation
import MetadataKit
import ToolKit

public enum BitcoinFetchError: Error {
    case fetchFailure(WalletAssetFetchError)
    case saveFailure(WalletAssetSaveError)
}

/// Types adopting `BitcoinEntryFetcherAPI` should be able to provide entries for Bitcoin and BitcoinCash assets
public protocol BitcoinEntryFetcherAPI {
    /// Fetches a `BitcoinEntry` from Wallet metadata
    func fetchOrCreateBitcoin() -> AnyPublisher<BitcoinEntry, BitcoinFetchError>
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

    func fetchOrCreateBitcoin() -> AnyPublisher<BitcoinEntry, BitcoinFetchError> {
        metadataEntryService.fetchEntry(type: BitcoinEntryPayload.self)
            .catch { [metadataEntryService] error -> AnyPublisher<BitcoinEntryPayload, BitcoinFetchError> in
                guard case .fetchFailed(.loadMetadataError(.notYetCreated)) = error else {
                    return .failure(.fetchFailure(error))
                }
                return generateBitcoinEntryPayload()
                    .publisher
                    .eraseToAnyPublisher()
                    .flatMap { payload -> AnyPublisher<BitcoinEntryPayload, BitcoinFetchError> in
                        metadataEntryService.save(node: payload)
                            .map { _ in payload }
                            .mapError(BitcoinFetchError.saveFailure)
                            .eraseToAnyPublisher()
                    }
                    .eraseToAnyPublisher()
            }
            .flatMap { [walletHolder] payload -> AnyPublisher<BitcoinEntry, BitcoinFetchError> in
                fetchWallet(walletHolder: walletHolder)
                    .map { BitcoinEntry(payload: payload, wallet: $0) }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}

private func fetchWallet(
    walletHolder: WalletHolderAPI
) -> AnyPublisher<NativeWallet, BitcoinFetchError> {
    walletHolder.walletStatePublisher
        .flatMap { state -> AnyPublisher<NativeWallet, BitcoinFetchError> in
            guard let wallet = state?.wallet else {
                return .failure(.fetchFailure(.notInitialized))
            }
            return .just(wallet)
        }
        .eraseToAnyPublisher()
}

/// Creates a new `BitcoinEntryPayload`
/// Note: At the time of writing this the entry for BTC on metadata is empty this is because
/// the wallet payload contains all the required info for a non-custodial BTC wallet.
private func generateBitcoinEntryPayload() -> Result<BitcoinEntryPayload, BitcoinFetchError> {
    .success(
        BitcoinEntryPayload()
    )
}
