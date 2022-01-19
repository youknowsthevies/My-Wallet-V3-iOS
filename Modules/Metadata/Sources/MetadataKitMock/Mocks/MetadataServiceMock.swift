// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation
import MetadataKit

final class MetadataServiceMock: MetadataServiceAPI {

    var initializeValue: AnyPublisher<MetadataState, MetadataInitialisationError> = .failure(
        .failedToDeriveRemoteMetadataNode(.failedToInitNodes)
    )

    func initialize(
        credentials: Credentials,
        masterKey: MasterKey,
        payloadIsDoubleEncrypted: Bool
    ) -> AnyPublisher<MetadataState, MetadataInitialisationError> {
        initializeValue
    }

    var initializeAndRecoverCredentialsValue =
        AnyPublisher<RecoveryContext, MetadataInitialisationAndRecoveryError>.failure(
            .invalidMnemonic(.invalidLength)
        )

    func initializeAndRecoverCredentials(
        from mnemonic: String
    ) -> AnyPublisher<RecoveryContext, MetadataInitialisationAndRecoveryError> {
        initializeAndRecoverCredentialsValue
    }

    var fetchValue: AnyPublisher<String, MetadataFetchError> = .failure(
        .failedToDeriveMetadataNode(.typeIndexMustBePositive)
    )

    func fetch(
        type: EntryType,
        state: MetadataState
    ) -> AnyPublisher<String, MetadataFetchError> {
        fetchValue
    }

    var saveValue: AnyPublisher<Void, MetadataSaveError> = .just(())

    func save(
        node jsonPayload: String,
        metadataType: EntryType,
        state: MetadataState
    ) -> AnyPublisher<Void, MetadataSaveError> {
        saveValue
    }
}
