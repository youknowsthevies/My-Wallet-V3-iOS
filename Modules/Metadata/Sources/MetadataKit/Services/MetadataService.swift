// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation
import ToolKit

final class MetadataService: MetadataServiceAPI {

    // MARK: - Private properties

    private let initialize: Initialize
    private let initializeAndRecoverCredentials: InitializeAndRecoverCredentials
    private let fetchEntry: FetchEntry
    private let saveEntry: SaveNodeToMetadata

    // MARK: - Init

    init(
        initialize: @escaping Initialize,
        initializeAndRecoverCredentials: @escaping InitializeAndRecoverCredentials,
        fetchEntry: @escaping FetchEntry,
        saveEntry: @escaping SaveNodeToMetadata
    ) {
        self.initialize = initialize
        self.initializeAndRecoverCredentials = initializeAndRecoverCredentials
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

    func initializeAndRecoverCredentials(
        from mnemonic: String
    ) -> AnyPublisher<RecoveryContext, MetadataInitialisationAndRecoveryError> {
        Deferred {
            Future<Mnemonic, MetadataInitialisationAndRecoveryError> { promise in
                switch Mnemonic.from(mnemonicString: mnemonic) {
                case .success(let mnemonic):
                    promise(.success(mnemonic))
                case .failure(let error):
                    promise(.failure(.invalidMnemonic(error)))
                }
            }
        }
        .flatMap { [initializeAndRecoverCredentials] mnemonic
            -> AnyPublisher<RecoveryContext, MetadataInitialisationAndRecoveryError> in
            initializeAndRecoverCredentials(mnemonic)
        }
        .eraseToAnyPublisher()
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
        unimplemented()
//        TODO: Uncomment this once we have better test coverage
//              for metadata write operations:
//        saveEntry(
//            .init(
//                payloadJson: jsonPayload,
//                type: metadataType,
//                nodes: state.metadataNodes
//            )
//        )
//        .mapError(MetadataSaveError.saveFailed)
//        .eraseToAnyPublisher()
    }
}
