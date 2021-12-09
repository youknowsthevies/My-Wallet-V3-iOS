// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization
import ToolKit

public enum WalletError: LocalizedError, Equatable {
    case unknown
    case payloadNotFound
    case initialization(WalletInitializationError)
    case decryption(WalletDecryptionError)

    public var errorDescription: String? {
        switch self {
        case .payloadNotFound:
            // TODO: Add Localization
            return "We could't find wallet data to decrypt"
        case .decryption(let error):
            return error.errorDescription
        case .initialization(let error):
            return error.errorDescription
        case .unknown:
            return ""
        }
    }

    static func map(from error: PayloadCryptoError) -> WalletError {
        switch error {
        case .decodingFailed:
            return .decryption(.genericDecodeError)
        case .noPassword:
            return .initialization(.invalidSecondPassword)
        case .keyDerivationFailed:
            return .initialization(.invalidSecondPassword)
        case .encryptionFailed:
            return .initialization(.invalidSecondPassword)
        case .decryptionFailed:
            return .initialization(.invalidSecondPassword)
        case .unknown:
            return .unknown
        case .noEncryptedWalletData:
            return .unknown
        case .unsupportedPayloadVersion:
            return .unknown
        case .failedToDecryptV1Payload:
            return .unknown
        }
    }
}

public enum WalletInitializationError: LocalizedError, Equatable {
    case unknown
    case missingSeedHex
    case metadataInitialization
    case needsSecondPassword
    case invalidSecondPassword

    public var errorDescription: String? {
        switch self {
        case .unknown:
            return ""
        case .missingSeedHex:
            return ""
        case .metadataInitialization:
            return ""
        case .needsSecondPassword:
            return ""
        case .invalidSecondPassword:
            return ""
        }
    }
}

public enum WalletDecryptionError: LocalizedError, Equatable {
    case decryptionError
    case decodeError(Error)
    case genericDecodeError
    case hdWalletCreation

    public var errorDescription: String? {
        switch self {
        case .decryptionError:
            return LocalizationConstants.WalletPayloadKit.Error.decryptionFailed
        case .decodeError(let error):
            return error.localizedDescription
        case .genericDecodeError:
            return LocalizationConstants.WalletPayloadKit.Error.unknown
        case .hdWalletCreation:
            unimplemented("WalletCore failure when creating HDWallet from seedHex")
        }
    }

    public static func == (lhs: WalletDecryptionError, rhs: WalletDecryptionError) -> Bool {
        switch (lhs, rhs) {
        case (.decryptionError, decryptionError):
            return true
        case (.decodeError(let lhsError), .decodeError(let rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        case (.genericDecodeError, .genericDecodeError):
            return true
        default:
            return false
        }
    }
}
