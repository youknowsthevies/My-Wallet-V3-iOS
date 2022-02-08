// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation

public enum MasterKeyError: Error {
    case failedToInstantiate(Error)
}

public struct MasterKey: Equatable {

    let privateKey: PrivateKey
}

extension MasterKey {

    public static func from(
        seedHex: String
    ) -> Result<MasterKey, MasterKeyError> {
        Result<PrivateKey, MasterKeyError>
            .success(PrivateKey.bitcoinKeyFrom(seedHex: seedHex))
            .mapError(MasterKeyError.failedToInstantiate)
            .map(MasterKey.init(privateKey:))
    }
}
