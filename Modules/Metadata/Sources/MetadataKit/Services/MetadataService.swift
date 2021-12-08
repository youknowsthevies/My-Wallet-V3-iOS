// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import Foundation
import NetworkError
import ToolKit

private enum NodeStatus: Equatable {
    case loaded(RemoteMetadataNodes)
    case notYetCreated
}

final class MetadataService: MetadataServiceAPI {

    // MARK: - Private properties

    private let loadMetadata: LoadRemoteMetadata

    // MARK: - Init

    init(loadMetadata: @escaping LoadRemoteMetadata) {
        self.loadMetadata = loadMetadata
    }

    // MARK: - Public methods

    func initialize(
        credentials: Credentials,
        masterKey: MasterKey,
        payloadIsDoubleEncrypted: Bool
    ) -> AnyPublisher<MetadataState, MetadataInitialisationError> {
        deriveSecondPasswordNode(credentials: credentials)
            .mapError(MetadataInitialisationError.failedToDeriveSecondPasswordNode)
            .publisher
            .flatMap { [initMetadataNodes] secondPasswordNode
                -> AnyPublisher<MetadataState, MetadataInitialisationError> in
                initMetadataNodes(
                    credentials,
                    masterKey,
                    payloadIsDoubleEncrypted,
                    secondPasswordNode
                )
            }
            .eraseToAnyPublisher()
    }

    func fetch(
        type: EntryType,
        state: MetadataState
    ) -> AnyPublisher<String, MetadataFetchError> {
        .just("Metadata Entry Payload")
    }

    func save(
        node jsonPayload: String,
        metadataType: EntryType,
        state: MetadataState
    ) -> AnyPublisher<Void, MetadataSaveError> {
        .just(())
    }

    // MARK: - Private methods

    private func initMetadataNodes(
        credentials: Credentials,
        masterKey: MasterKey,
        payloadIsDoubleEncrypted: Bool,
        secondPasswordNode: SecondPasswordNode
    ) -> AnyPublisher<MetadataState, MetadataInitialisationError> {
        loadNodes(credentials: credentials)
            .catch { error -> AnyPublisher<(NodeStatus, SecondPasswordNode), MetadataInitialisationError> in
                guard case .failedToLoadRemoteMetadataNode(let loadError) = error else {
                    return .failure(error)
                }
                guard case .notYetCreated = loadError else {
                    return .failure(error)
                }
                return .just((.notYetCreated, secondPasswordNode))
            }
            .flatMap { nodeStatus, secondPasswordNode
                -> AnyPublisher<MetadataState, MetadataInitialisationError> in
                switch nodeStatus {
                case .notYetCreated:
                    // TODO: Implement node generation
                    unimplemented()
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

    private func loadNodes(
        credentials: Credentials
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
}
