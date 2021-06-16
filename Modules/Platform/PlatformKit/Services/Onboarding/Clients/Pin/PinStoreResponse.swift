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

    // TODO: use the imaginary cap approach when backend updates the backoff algorithm
//    private var attemptsRemaining: Int? {
//        guard let remaining = self.remaining else {
//            return nil
//        }
//        switch remaining {
//        case 1000: // 1s back off, 5 attempts left
//            return 5
//        case 5000: // 5s back off, 4 attempts left
//            return 4
//        case 10000: // 10s back off, 3 attemtps left
//            return 3
//        case 300000: // 5m back off, 2 attempts left
//            return 2
//        case 3000000: // 50m back off, 1 attempts left
//            return 1
//        default: // any other higher back off, 0 attempts left
//            return 0
//        }
//    }

    // TODO: Use hardcoded value for now, replace with the actual lock time returned from backend
    private var lockTimeSeconds: Int {
        switch UserDefaults.standard.integer(forKey: "WrongPinAttempts") {
        case 1...3:
            return 10 // 1-3 wrong attempts, lock for 10 seconds
        case 4:
            return 300 // 4 wrong attempts, lock for 5 minutes
        case 5:
            return 3600 // 5 wrong attempts, lock for 1 hour
        default:
            return 86400 // 6+ wrong attempts, lock for 24 hours
        }
    }

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

    public func toPinError() -> PinError {
        // First verify that the status code was received
        guard let code = statusCode else {
            return PinError.serverError(LocalizationConstants.Errors.genericError)
        }

        switch code {
        case .deleted:
            return PinError.tooManyAttempts
        case .incorrect:
            // Add wrong PIN attempt count by 1
            UserDefaults.standard.set(
                UserDefaults.standard.integer(forKey: "WrongPinAttempts") + 1,
                forKey: "WrongPinAttempts"
            )
            // Record the timestamp when a wrong attempt is made
            UserDefaults.standard.set(
                NSDate().timeIntervalSince1970,
                forKey: "LastWrongPinTimestamp"
            )
            let message = LocalizationConstants.Pin.incorrect
            return PinError.incorrectPin(message, lockTimeSeconds)
        case .backoff:
            // Calculate elapsed time and remaining lock time
            let lastWrongPinTimestamp = UserDefaults.standard.object(forKey: "LastWrongPinTimestamp") as! TimeInterval
            let elapsed = Int(NSDate().timeIntervalSince1970 - lastWrongPinTimestamp)
            // Ensure no negative number
            let remaining = max(lockTimeSeconds - elapsed, 0)
            let message = LocalizationConstants.Pin.backoff
            return PinError.backoff(message, remaining)
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
            error: communicatorError.localizedDescription,
            remaining: nil,
            pinDecryptionValue: nil,
            key: nil,
            value: nil
        )
    }
}
