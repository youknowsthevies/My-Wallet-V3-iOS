// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import MetadataKit

extension MetadataFetchError: Equatable {

    public static func == (
        lhs: MetadataFetchError,
        rhs: MetadataFetchError
    ) -> Bool {
        switch (lhs, rhs) {
        case (.loadMetadataError(let lhsError), .loadMetadataError(let rhsError)):
            return lhsError == rhsError
        case (.failedToDeriveMetadataNode(let lhsError), .failedToDeriveMetadataNode(let rhsError)):
            return lhsError == rhsError
        case (.decodingError(let lhsError), .decodingError(let rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        default:
            return false
        }
    }
}

extension LoadRemoteMetadataError: Equatable {

    public static func == (
        lhs: LoadRemoteMetadataError,
        rhs: LoadRemoteMetadataError
    ) -> Bool {
        switch (lhs, rhs) {
        case (.notYetCreated, .notYetCreated):
            return true
        case (.networkError(let lhsError), .networkError(let rhsError)):
            return lhsError == rhsError
        case (.decryptionFailed(let lhsError), .decryptionFailed(let rhsError)):
            return lhsError == rhsError
        default:
            return false
        }
    }
}

extension DecryptMetadataError: Equatable {

    public static func == (
        lhs: DecryptMetadataError,
        rhs: DecryptMetadataError
    ) -> Bool {
        switch (lhs, rhs) {
        case (.invalidPayload, .invalidPayload):
            return true
        case (
            .failedToDecryptWithRegularKey(
                let lhsPayload, let lhsValidationError
            ),
            .failedToDecryptWithRegularKey(
                let rhsPayload, let rhsValidationError
            )
        ):
            return lhsPayload == rhsPayload && lhsValidationError == rhsValidationError
        case (.failedToDecrypt(let lhsError), .failedToDecrypt(let rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        default:
            return false
        }
    }
}
