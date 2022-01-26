// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public typealias WalletRepoStateEncoding = (_ value: WalletRepoState) -> Result<Data, WalletRepoStateCodingError>
public typealias WalletRepoStateDecoding = (_ data: Data) -> Result<WalletRepoState, WalletRepoStateCodingError>

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
