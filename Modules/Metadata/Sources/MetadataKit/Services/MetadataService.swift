// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation

final class MetadataService: MetadataServiceAPI {

    // MARK: - Private properties

    private let initialize: Initialize
    private let fetchEntry: FetchEntry
    private let saveEntry: SaveNodeToMetadata

    // MARK: - Init

    init(
        initialize: @escaping Initialize,
        fetchEntry: @escaping FetchEntry,
        saveEntry: @escaping SaveNodeToMetadata
    ) {
        self.initialize = initialize
        self.fetchEntry = fetchEntry
        self.saveEntry = saveEntry
    }

    // MARK: - Public methods

    func initialize(
        credentials: Credentials,
        masterKey: MasterKey,
        payloadIsDoubleEncrypted: Bool
    ) -> AnyPublisher<MetadataState, MetadataInitialisationError> {
        initialize(credentials, masterKey, payloadIsDoubleEncrypted)
    }

    func fetch(
        type: EntryType,
        state: MetadataState
    ) -> AnyPublisher<String, MetadataFetchError> {
        fetchEntry(type, state.metadataNodes)
    }

    func save(
        node jsonPayload: String,
        metadataType: EntryType,
        state: MetadataState
    ) -> AnyPublisher<Void, MetadataSaveError> {
        saveEntry(
            .init(
                payloadJson: jsonPayload,
                type: metadataType,
                nodes: state.metadataNodes
            )
        )
        .mapError(MetadataSaveError.saveFailed)
        .eraseToAnyPublisher()
    }
}
