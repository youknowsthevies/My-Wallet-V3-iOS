// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization

public enum WalletError: LocalizedError, Equatable {
    case initialization(WalletInitializationError)
    case decryption(WalletDecryptionError)

    public var errorDescription: String? {
        switch self {
        case .decryption(let error):
            return error.errorDescription
        case .initialization(let error):
            return error.errorDescription
        }
    }
}

public enum WalletInitializationError: LocalizedError, Equatable {
    case none

    public var errorDescription: String? {
        switch self {
        case .none:
            return ""
        }
    }
}

public enum WalletDecryptionError: LocalizedError, Equatable {
    case wrongPassword

    public var errorDescription: String? {
        switch self {
        case .wrongPassword:
            return LocalizationConstants.WalletPayloadKit.Error.decryptionFailed
        }
    }
}
