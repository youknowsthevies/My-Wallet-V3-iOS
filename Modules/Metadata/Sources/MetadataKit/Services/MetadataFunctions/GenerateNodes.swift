// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation
import MetadataHDWalletKit
import NetworkError
import ToolKit

public enum GenerateNodesError: Error {
    case failedToDeriveRemoteNodes
    case failedToEncodeToJSONString(EncodingError)
    case failedToSaveNode(SaveMetadataError)
}

typealias GenerateNodes =
    (MasterKey, SecondPasswordNode)
        -> AnyPublisher<MetadataState, GenerateNodesError>

func provideGenerateNodes(
    fetch: @escaping FetchMetadataEntry,
    put: @escaping PutMetadataEntry
) -> GenerateNodes {
    { masterKey, secondPasswordNode in
        generateNodes(
            masterKey: masterKey,
            secondPasswordNode: secondPasswordNode,
            saveMetadata: provideSaveMetadata(
                fetch: fetch,
                put: put
            )
        )
    }
}

func generateNodes(
    masterKey: MasterKey,
    secondPasswordNode: SecondPasswordNode,
    saveMetadata: @escaping SaveMetadata
) -> AnyPublisher<MetadataState, GenerateNodesError> {
    remoteMetadataHdNodes(masterKey: masterKey)
        .mapError()
        .flatMap { remoteNodes
            -> AnyPublisher<RemoteMetadataNodes, GenerateNodesError> in
            guard let remoteNodes = remoteNodes else {
                return .failure(.failedToDeriveRemoteNodes)
            }
            return .just(remoteNodes)
        }
        .eraseToAnyPublisher()
        .flatMap { remoteMetadataHdNodes
            -> AnyPublisher<MetadataState, GenerateNodesError> in
            Just(remoteMetadataHdNodes)
                .map(\.payload)
                .map(\.response)
                .flatMap { remoteMetadataHdNodes -> AnyPublisher<String, GenerateNodesError> in
                    remoteMetadataHdNodes.encodeToJSONString()
                        .mapError(GenerateNodesError.failedToEncodeToJSONString)
                        .publisher
                        .eraseToAnyPublisher()
                }
                .flatMap { remoteMetadataHdNodesString
                    -> AnyPublisher<MetadataState, GenerateNodesError> in
                    saveMetadata(
                        .init(
                            payloadJson: remoteMetadataHdNodesString,
                            metadata: secondPasswordNode.metadataNode
                        )
                    )
                    .mapError(GenerateNodesError.failedToSaveNode)
                    .map { _ -> MetadataState in
                        MetadataState(
                            metadataNodes: remoteMetadataHdNodes,
                            secondPasswordNode: secondPasswordNode
                        )
                    }
                    .eraseToAnyPublisher()
                }
                .eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
}

private func remoteMetadataHdNodes(
    masterKey: MasterKey
) -> AnyPublisher<RemoteMetadataNodes?, Never> {
    MetadataDerivation().deriveMetadataNode(node: masterKey)
        .flatMap { metadataNode -> Result<RemoteMetadataNodes, MetadataDerivationError> in
            MetadataDerivation().deriveSharedMetadataNode(node: masterKey)
                .map { sharedMetadataNode -> RemoteMetadataNodes in
                    RemoteMetadataNodes(
                        sharedMetadataNode: sharedMetadataNode,
                        metadataNode: metadataNode
                    )
                }
        }
        .map { $0 }
        .flatMapError { _ -> Result<RemoteMetadataNodes?, Never> in
            .success(nil)
        }
        .publisher
        .eraseToAnyPublisher()
}
