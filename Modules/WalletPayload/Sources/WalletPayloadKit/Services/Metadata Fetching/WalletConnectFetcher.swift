// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation
import MetadataKit
import ToolKit

public protocol WalletConnectFetcherAPI {
    func fetchSessions() -> AnyPublisher<String, WalletAssetFetchError>

    func update(v1Sessions: String) -> AnyPublisher<Void, WalletAssetSaveError>
}

final class WalletConnectFetcher: WalletConnectFetcherAPI {

    private let metadataEntryService: WalletMetadataEntryServiceAPI

    init(metadataEntryService: WalletMetadataEntryServiceAPI) {
        self.metadataEntryService = metadataEntryService
    }

    func fetchSessions() -> AnyPublisher<String, WalletAssetFetchError> {
        metadataEntryService.fetchEntry(type: WalletConnectEntryPayload.self)
            .flatMap { entryPayload -> AnyPublisher<String, WalletAssetFetchError> in
                guard let sessions = entryPayload.sessions else {
                    return .failure(.unavailable)
                }
                return .just(sessions)
            }
            .eraseToAnyPublisher()
    }

    func update(v1Sessions: String) -> AnyPublisher<Void, WalletAssetSaveError> {
        let node = WalletConnectEntryPayload(sessions: v1Sessions)
        return metadataEntryService.save(node: node)
            .mapToVoid()
    }
}
