// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation
import MetadataKit
import ToolKit

public enum WalletAssetFetchError: Error {
    case notInitialized
    case fetchFailed(MetadataFetchError)
}

public protocol WalletMetadataEntryServiceAPI {
    /// Fetches a node entry from Metadata for the specified entry type
    /// - Parameter type: The type of Entry to be returned
    /// - Returns: An `AnyPublisher<Entry, WalletCoinFetchError>`
    func fetchEntry<Entry: MetadataNodeEntry>(
        type: Entry.Type
    ) -> AnyPublisher<Entry, WalletAssetFetchError>
}

final class WalletMetadataEntryService: WalletMetadataEntryServiceAPI {

    private let walletHolder: WalletHolderAPI
    private let metadataService: MetadataServiceAPI

    init(
        walletHolder: WalletHolderAPI,
        metadataService: MetadataServiceAPI
    ) {
        self.walletHolder = walletHolder
        self.metadataService = metadataService
    }

    func fetchEntry<Entry: MetadataNodeEntry>(
        type: Entry.Type
    ) -> AnyPublisher<Entry, WalletAssetFetchError> {
        walletHolder.walletStatePublisher
            .flatMap { state -> AnyPublisher<MetadataState, WalletAssetFetchError> in
                guard let metadata = state?.metadata else {
                    return .failure(.notInitialized)
                }
                return .just(metadata)
            }
            .flatMap { [metadataService] metadataState -> AnyPublisher<Entry, WalletAssetFetchError> in
                metadataService.fetchEntry(with: metadataState)
                    .mapError(WalletAssetFetchError.fetchFailed)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}
