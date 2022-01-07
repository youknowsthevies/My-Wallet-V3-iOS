// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import MetadataKit

import Combine
import TestKit
import ToolKit
import XCTest

class MockMetadataService: MetadataServiceAPI {

    var initializeMetadata = PassthroughSubject<MetadataState, MetadataInitialisationError>()

    func initialize(
        credentials: Credentials,
        masterKey: MasterKey,
        payloadIsDoubleEncrypted: Bool
    ) -> AnyPublisher<MetadataState, MetadataInitialisationError> {
        initializeMetadata.eraseToAnyPublisher()
    }

    func initializeAndRecoverCredentials(
        from mnemonic: String
    ) -> AnyPublisher<(MetadataState, Credentials), MetadataInitialisationAndRecoveryError> {
        .empty()
    }

    func fetch(
        type: EntryType,
        state: MetadataState
    ) -> AnyPublisher<String, MetadataFetchError> {
        .empty()
    }

    func save(
        node jsonPayload: String,
        metadataType: EntryType,
        state: MetadataState
    ) -> AnyPublisher<Void, MetadataSaveError> {
        .empty()
    }
}
