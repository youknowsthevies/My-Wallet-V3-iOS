// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation

typealias Initialize =
    (Credentials, MasterKey, Bool) -> AnyPublisher<MetadataState, MetadataInitialisationError>

func provideInitialize(
    fetch: @escaping FetchMetadataEntry,
    put: @escaping PutMetadataEntry
) -> Initialize {
    provideInitialize(
        initMetadataNodes: provideInitMetadataNodes(
            fetch: fetch,
            put: put
        )
    )
}

func provideInitialize(
    initMetadataNodes: @escaping InitMetadataNodes
) -> Initialize {
    { credentials, masterKey, payloadIsDoubleEncrypted in
        initialize(
            credentials: credentials,
            masterKey: masterKey,
            payloadIsDoubleEncrypted: payloadIsDoubleEncrypted,
            initMetadataNodes: initMetadataNodes
        )
    }
}

private func initialize(
    credentials: Credentials,
    masterKey: MasterKey,
    payloadIsDoubleEncrypted: Bool,
    initMetadataNodes: @escaping InitMetadataNodes
) -> AnyPublisher<MetadataState, MetadataInitialisationError> {
    deriveSecondPasswordNode(credentials: credentials)
        .mapError(MetadataInitialisationError.failedToDeriveSecondPasswordNode)
        .publisher
        .flatMap { secondPasswordNode
            -> AnyPublisher<MetadataState, MetadataInitialisationError> in
            initMetadataNodes(
                .init(
                    credentials: credentials,
                    masterKey: masterKey,
                    payloadIsDoubleEncrypted: payloadIsDoubleEncrypted,
                    secondPasswordNode: secondPasswordNode
                )
            )
        }
        .eraseToAnyPublisher()
}
