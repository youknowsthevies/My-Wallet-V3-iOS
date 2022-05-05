// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization
import ToolKit

// TODO: Add Localization
public enum WalletError: LocalizedError, Equatable {
    case unknown
    case payloadNotFound
    case initialization(WalletInitializationError)
    case decryption(WalletDecryptionError)
    case encryption(WalletEncodingError)
    case recovery(WalletRecoverError)
    case upgrade(WalletUpgradeError)

    public var errorDescription: String? {
        switch self {
        case .payloadNotFound:
            return "We could't find wallet data to decrypt"
        case .decryption(let error):
            return error.errorDescription
        case .initialization(let error):
            return error.errorDescription
        case .recovery(let error):
            return error.errorDescription
        case .encryption(let error):
            return error.errorDescription
        case .upgrade(let error):
            return error.localizedDescription
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
    case missingWallet
    case missingSeedHex
    case metadataInitialization
    case needsSecondPassword
    case invalidSecondPassword

    public var errorDescription: String? {
        switch self {
        case .unknown:
            return ""
        case .missingWallet:
            return "Initializating wallet failed due to missing data"
        case .missingSeedHex:
            return "Initializating wallet failed due to missing seedHex"
        case .metadataInitialization:
            return "Initializating wallet failed due to metadata error"
        case .needsSecondPassword:
            return "Wallet is double encrypted"
        case .invalidSecondPassword:
            return "Second password is invalid"
        }
    }
}

public enum WalletRecoverError: LocalizedError, Equatable {
    case unknown
    case invalidMnemonic
    case unableToRecoverFromMetadata
    case failedToRecoverWallet

    public var errorDescription: String? {
        switch self {
        case .unknown:
            return "Recovery failure"
        case .invalidMnemonic:
            return "Recovery failed due to invalid mnemonic"
        case .failedToRecoverWallet:
            return "Failed to recover wallet"
        case .unableToRecoverFromMetadata:
            // Intentionally nil
            // This error indicates that the wallet from a mnemonic was not previously created by Blockchain.com
            // but another wallet provider, so in this case we will import a wallet and create a new account.
            return nil
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

public enum WalletEncodingError: LocalizedError, Equatable {
    case encryptionFailure
    case encodingError(EncodingError)
    case genericFailure
    case expectedEncryptedPayload

    public static func == (lhs: WalletEncodingError, rhs: WalletEncodingError) -> Bool {
        switch (lhs, rhs) {
        case (.encryptionFailure, encryptionFailure):
            return true
        case (.genericFailure, genericFailure):
            return true
        case (.expectedEncryptedPayload, expectedEncryptedPayload):
            return true
        case (.encodingError(let lhsError), .encodingError(let rhsError)):
            return lhsError.errorDescription == rhsError.errorDescription
        default:
            return false
        }
    }
}
