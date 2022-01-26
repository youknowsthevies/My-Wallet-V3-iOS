// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation

typealias FetchEntry =
    (EntryType, RemoteMetadataNodes) -> AnyPublisher<String, MetadataFetchError>

func provideFetchEntry(
    fetch: @escaping FetchMetadataEntry
) -> FetchEntry {
    provideFetchEntry(
        loadMetadata: provideLoadRemoteMetadata(
            fetch: fetch
        )
    )
}

func provideFetchEntry(
    loadMetadata: @escaping LoadRemoteMetadata
) -> FetchEntry {
    { type, metadataNodes in
        fetchEntry(
            type: type,
            metadataNodes: metadataNodes,
            loadMetadata: loadMetadata
        )
    }
}

private func fetchEntry(
    type: EntryType,
    metadataNodes: RemoteMetadataNodes,
    loadMetadata: @escaping LoadRemoteMetadata
) -> AnyPublisher<String, MetadataFetchError> {
    AnyPublisher.just(metadataNodes)
        .map(\.metadataNode)
        .flatMap { key -> AnyPublisher<MetadataNode, MetadataFetchError> in
            MetadataNode.from(
                metaDataHDNode: key,
                metadataDerivation: MetadataDerivation(),
                for: type
            )
            .publisher
            .mapError(MetadataFetchError.failedToDeriveMetadataNode)
            .eraseToAnyPublisher()
        }
        .flatMap { metadataNode -> AnyPublisher<String, MetadataFetchError> in
            loadMetadata(metadataNode)
                .mapError(MetadataFetchError.loadMetadataError)
                .eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
}
