// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

typealias WalletRepoStateEncoding = (_ value: WalletRepoState) -> Result<Data, WalletRepoStateCodingError>
typealias WalletRepoStateDecoding = (_ data: Data) -> Result<WalletRepoState, WalletRepoStateCodingError>

public enum WalletRepoStateCodingError: LocalizedError, Equatable {
    case encodingFailed(Error)
    case decodingFailed(Error)

    public var errorDescription: String? {
        switch self {
        case .decodingFailed(let error):
            return "Wallet Repo Decoding Failure: \(error.localizedDescription)"
        case .encodingFailed(let error):
            return "Wallet Repo Encoding Failure: \(error.localizedDescription)"
        }
    }

    public static func == (lhs: WalletRepoStateCodingError, rhs: WalletRepoStateCodingError) -> Bool {
        switch (lhs, rhs) {
        case (.encodingFailed(let lhsError), .encodingFailed(let rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        case (.decodingFailed(let lhsError), .decodingFailed(let rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        default:
            return false
        }
    }
}

func walletRepoStateEncoder(
    _ value: WalletRepoState
) -> Result<Data, WalletRepoStateCodingError> {
    Result {
        try JSONEncoder().encode(value)
    }
    .mapError(WalletRepoStateCodingError.encodingFailed)
}

func walletRepoStateDecoder(
    _ data: Data
) -> Result<WalletRepoState, WalletRepoStateCodingError> {
    Result {
        try JSONDecoder().decode(WalletRepoState.self, from: data)
    }
    .mapError(WalletRepoStateCodingError.decodingFailed)
}
