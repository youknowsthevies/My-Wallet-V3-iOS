// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import CommonCryptoKit
import Foundation
import ToolKit

public enum SharedKeyParsingServiceError: Error {
    /// Invalid component count - expects a count of 2 in the format:
    case invalidComponentCount

    /// Invalid shared key length - expects `36` characters
    case invalidSharedKeyLength

    /// Password decoding failure
    case passwordDecodingFailure
}

public protocol SharedKeyParsingServiceAPI {
    /// Maps a wallet pairing code (sharedKey and password) into a `KeyDataPair`
    /// - Parameter pairingCode: the pairing code build from shared-key and password separated by a single `|`.
    /// - Returns: A `KeyDataPair` struct in which `key` is the password and `data` is the shared-key
    func parsr(pairingCode: String) -> AnyPublisher<KeyDataPair<String, String>, SharedKeyParsingServiceError>
}

/// A shared key parsing service
public final class SharedKeyParsingService {

    // MARK: - Types

    private enum Constant {
        static let componentCount = 2
        static let sharedKeyLength = 36
        static let delimiter: Character = "|"
    }

    public func parse(pairingCode: String) -> Result<KeyDataPair<String, String>, SharedKeyParsingServiceError> {
        let components = pairingCode.split(separator: Constant.delimiter)
        guard components.count == Constant.componentCount else {
            return .failure(.invalidComponentCount)
        }

        // Extract shared key
        let sharedKey = String(components[0])
        guard sharedKey.count == Constant.sharedKeyLength else {
            return .failure(.invalidSharedKeyLength)
        }

        // Extract password
        let hexEncodedPassword = String(components[1])
        let passwordData = Data(hex: hexEncodedPassword)
        guard let password = String(data: passwordData, encoding: .utf8) else {
            return .failure(.passwordDecodingFailure)
        }

        // Construct a `KeyDataPair` from the password and the shared key
        return .success(KeyDataPair(key: password, data: sharedKey))
    }
}
