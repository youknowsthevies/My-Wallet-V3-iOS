// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine

// Types adopting `WalletFetcherAPI` should provide a way to load and initialize a Blockchain Wallet
public protocol WalletFetcherAPI {

    /// Fetches and initializes a wallet using the given password
    /// - Parameter password: A `String` to be used as the password for fetching the wallet
    func fetch(using password: String) -> AnyPublisher<Bool, WalletError>
}

final class WalletFetcher: WalletFetcherAPI {

    func fetch(using password: String) -> AnyPublisher<Bool, WalletError> {
        // 0. load the payload
        // 1. decrypt the payload
        // 2. save the guid to metadata (revisit this)
        // 3. load the metadata
        // 4. fetch and store:
        //    a) wallet options
        //    b) account info
        // 5. Success (or failure)
        Just(false)
            .setFailureType(to: WalletError.self)
            .eraseToAnyPublisher()
    }

    // MARK: - Private
}
