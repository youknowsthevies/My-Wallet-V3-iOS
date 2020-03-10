//
//  SharedKeyParsingService.swift
//  PlatformKit
//
//  Created by Daniel Huri on 20/01/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import ToolKit
import CommonCryptoKit

/// A shared key parsing service
final class SharedKeyParsingService {
    
    // MARK: - Types
    
    private struct Constant {
        static let componentCount = 2
        static let sharedKeyLength = 36
        static let delimiter: Character = "|"
    }
    
    /// A potential error raised during the parsing
    private enum ServiceError: Error {
        
        /// Invalid component count - expects a count of 2 in the format:
        case invalidComponentCount
        
        /// Invalid shared key length - expects `36` characters
        case invalidSharedKeyLength
        
        /// Password decoding failure
        case passwordDecodingFailure
    }
    
    /// Maps a wallet pairing code (sharedKey and password) into a `KeyDataPair`
    /// - Parameter pairingCode: the pairing code build from shared-key and password separated by a single `|`.
    /// - Returns: A `KeyDataPair` struct in which `key` is the password and `data` is the shared-key
    func parse(pairingCode: String) throws -> KeyDataPair<String, String> {
        let components = pairingCode.split(separator: Constant.delimiter)
        guard components.count == Constant.componentCount else {
            throw ServiceError.invalidComponentCount
        }
        
        // Extract shared key
        
        let sharedKey = String(components[0])
        guard sharedKey.count == Constant.sharedKeyLength else {
            throw ServiceError.invalidSharedKeyLength
        }
        
        // Extract password
        
        let hexEncodedPassword = String(components[1])
        let passwordData = Data(hex: hexEncodedPassword)
        guard let password = String(data: passwordData, encoding: .utf8) else {
            throw ServiceError.passwordDecodingFailure
        }
        
        /// Construct a `KeyDataPair` from the password and the shared key
        
        return KeyDataPair(key: password, data: sharedKey)
    }
}
