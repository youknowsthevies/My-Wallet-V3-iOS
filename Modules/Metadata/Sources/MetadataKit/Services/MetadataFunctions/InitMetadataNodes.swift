// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation

struct InitMetadataNodesInput {
    var credentials: Credentials
    var masterKey: MasterKey
    var payloadIsDoubleEncrypted: Bool
    var secondPasswordNode: SecondPasswordNode
}

typealias InitMetadataNodes =
    (InitMetadataNodesInput) -> AnyPublisher<MetadataState, MetadataInitialisationError>

enum NodeStatus: Equatable {
    case loaded(RemoteMetadataNodes)
    case notYetCreated
}

func provideInitMetadataNodes(
    fetch: @escaping FetchMetadataEntry,
    put: @escaping PutMetadataEntry
) -> InitMetadataNodes {
    let loadMetadata = provideLoadRemoteMetadata(
        fetch: fetch
    )
    let loadNodes = provideLoadNodes(fetch: fetch)
    let generateNodes = provideGenerateNodes(
        fetch: fetch,
        put: put
    )
    return provideInitMetadataNodes(
        loadNodes: loadNodes,
        loadMetadata: loadMetadata,
        generateNodes: generateNodes
    )
}

func provideInitMetadataNodes(
    loadNodes: @escaping LoadNodes,
    loadMetadata: @escaping LoadRemoteMetadata,
    generateNodes: @escaping GenerateNodes
) -> InitMetadataNodes {
    { input in
        initMetadataNodes(
            input: input,
            loadNodes: loadNodes,
            loadMetadata: loadMetadata,
            generateNodes: generateNodes
        )
    }
}

private func initMetadataNodes(
    input: InitMetadataNodesInput,
    loadNodes: @escaping LoadNodes,
    loadMetadata: @escaping LoadRemoteMetadata,
    generateNodes: @escaping GenerateNodes
) -> AnyPublisher<MetadataState, MetadataInitialisationError> {
    loadNodes(input.credentials)
        .catch { error -> AnyPublisher<(NodeStatus, SecondPasswordNode), MetadataInitialisationError> in
            guard case .failedToLoadRemoteMetadataNode(let loadError) = error else {
                return .failure(error)
            }
            guard case .notYetCreated = loadError else {
                return .failure(error)
            }
            return .just((.notYetCreated, input.secondPasswordNode))
        }
        .flatMap { [generateNodes] nodeStatus, secondPasswordNode
            -> AnyPublisher<MetadataState, MetadataInitialisationError> in
            switch nodeStatus {
            case .notYetCreated:
                return generateNodes(
                    input.masterKey,
                    secondPasswordNode
                )
                .mapError(MetadataInitialisationError.failedToGenerateNodes)
                .eraseToAnyPublisher()
            case .loaded(let metadataNodes):
                return .just(
                    MetadataState(
                        metadataNodes: metadataNodes,
                        secondPasswordNode: secondPasswordNode
                    )
                )
            }
        }
        .eraseToAnyPublisher()
}

typealias LoadNodes =
    (Credentials) -> AnyPublisher<(NodeStatus, SecondPasswordNode), MetadataInitialisationError>

func provideLoadNodes(
    fetch: @escaping FetchMetadataEntry
) -> LoadNodes {
    provideLoadNodes(
        loadMetadata: provideLoadRemoteMetadata(
            fetch: fetch
        )
    )
}

func provideLoadNodes(
    loadMetadata: @escaping LoadRemoteMetadata
) -> LoadNodes {
    { credentials in
        loadNodes(
            credentials: credentials,
            loadMetadata: loadMetadata
        )
    }
}

private func loadNodes(
    credentials: Credentials,
    loadMetadata: @escaping LoadRemoteMetadata
) -> AnyPublisher<(NodeStatus, SecondPasswordNode), MetadataInitialisationError> {

    func load(
        secondPasswordNode: SecondPasswordNode
    ) -> AnyPublisher<(NodeStatus, SecondPasswordNode), MetadataInitialisationError> {
        loadMetadata(secondPasswordNode.metadataNode)
            .mapError(MetadataInitialisationError.failedToLoadRemoteMetadataNode)
            .flatMap { remoteMetadataNodesString
                -> AnyPublisher<RemoteMetadataNodesResponse, MetadataInitialisationError> in
                remoteMetadataNodesString
                    .decodeJSON(
                        to: RemoteMetadataNodesResponse.self
                    )
                    .mapError(MetadataInitialisationError.failedToDecodeRemoteMetadataNode)
                    .publisher
                    .eraseToAnyPublisher()
            }
            .flatMap { remoteMetadataNodesResponse
                -> AnyPublisher<NodeStatus, MetadataInitialisationError> in
                initNodes(
                    remoteMetadataNodesResponse: remoteMetadataNodesResponse
                )
                .mapError(MetadataInitialisationError.failedToDeriveRemoteMetadataNode)
                .publisher
                .map(NodeStatus.loaded)
                .eraseToAnyPublisher()
            }
            .map { nodeStatus -> (NodeStatus, SecondPasswordNode) in
                (nodeStatus, secondPasswordNode)
            }
            .eraseToAnyPublisher()
    }

    return deriveSecondPasswordNode(credentials: credentials)
        .mapError(MetadataInitialisationError.failedToDeriveSecondPasswordNode)
        .publisher
        .flatMap { secondPasswordNode
            -> AnyPublisher<(NodeStatus, SecondPasswordNode), MetadataInitialisationError> in
            load(secondPasswordNode: secondPasswordNode)
        }
        .eraseToAnyPublisher()
}
