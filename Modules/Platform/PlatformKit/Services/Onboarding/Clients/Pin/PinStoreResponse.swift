// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization
import NetworkKit

public struct PinStoreResponse: Decodable & Error {

    public enum StatusCode: Int, Decodable {
        case success = 0 // Pin retry succeeded
        case deleted = 1 // Pin retry failed and data was deleted from store
        case incorrect = 2 // Incorrect pin
        case backoff = 5 // PIN is locked due to exponential backoff
    }

    private enum CodingKeys: String, CodingKey {
        case code = "code"
        case error = "error"
        case remaining = "remaining"
        case pinDecryptionValue = "success"
        case key = "key"
        case value = "value"
    }

    /// This is a status code from the server
    public let statusCode: StatusCode?

    /// This is an error string from the server or nil
    public let error: String?

    /// This is the remaining PIN locked time in milliseconds due to exponential back off
    public let remaining: Int?

    /// The PIN decryption value from the server
    public let pinDecryptionValue: String?

    /// Pin code lookup key
    let key: String?

    /// Encryption string
    let value: String?
}

extension PinStoreResponse {

    /// Is the response successful
    public var isSuccessful: Bool {
        statusCode == .success && error == nil
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        statusCode = try values.decode(StatusCode.self, forKey: .code)
        pinDecryptionValue = try values.decodeIfPresent(String.self, forKey: .pinDecryptionValue)
        key = try values.decodeIfPresent(String.self, forKey: .key)
        value = try values.decodeIfPresent(String.self, forKey: .value)
        error = try values.decodeIfPresent(String.self, forKey: .error)
        remaining = try values.decodeIfPresent(Int.self, forKey: .remaining)
    }

    public func toPinError(pinLockTime: Int = 0) -> PinError {
        // First verify that the status code was received
        guard let code = statusCode else {
            return PinError.serverError(LocalizationConstants.Errors.genericError)
        }

        switch code {
        case .deleted:
            return PinError.tooManyAttempts
        case .incorrect:
            let message = LocalizationConstants.Pin.incorrect
            return PinError.incorrectPin(message, pinLockTime)
        case .backoff:
            let message = LocalizationConstants.Pin.backoff
            return PinError.backoff(message, pinLockTime)
        case .success:
            // Should not happen because this is an error response
            return PinError.serverError(LocalizationConstants.Errors.genericError)
        }
    }
}

extension PinStoreResponse: FromNetworkErrorConvertible {

    public static func from(
        _ communicatorError: NetworkError
    ) -> PinStoreResponse {
        PinStoreResponse(
            statusCode: nil,
            error: String(describing: communicatorError),
            remaining: nil,
            pinDecryptionValue: nil,
            key: nil,
            value: nil
        )
    }
}
