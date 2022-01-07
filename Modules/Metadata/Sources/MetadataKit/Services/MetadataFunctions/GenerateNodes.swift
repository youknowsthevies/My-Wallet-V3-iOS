// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation
import MetadataHDWalletKit
import NetworkError
import ToolKit

public enum GenerateNodesError: Error {
    case failedToDeriveRemoteNodes(MetadataDerivationError)
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
    deriveRemoteMetadataHdNodes(from: masterKey)
        .publisher
        .mapError(GenerateNodesError.failedToDeriveRemoteNodes)
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
