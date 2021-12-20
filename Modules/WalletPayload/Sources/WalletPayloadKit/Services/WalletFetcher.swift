// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation
import ToolKit

// Types adopting `WalletFetcherAPI` should provide a way to load and initialize a Blockchain Wallet
public protocol WalletFetcherAPI {

    /// Fetches and initializes a wallet using the given password
    /// - Parameter password: A `String` to be used as the password for fetching the wallet
    func fetch(using password: String) -> AnyPublisher<EmptyValue, WalletError>

    /// Fetches and initializes a wallet using the given password and a second password
    /// - Parameter password: A `String` to be used as the password for fetching the wallet
    func fetch(using password: String, secondPassword: String) -> AnyPublisher<EmptyValue, WalletError>
}

final class WalletFetcher: WalletFetcherAPI {

    private let walletRepo: WalletRepo
    private let payloadCrypto: PayloadCryptoAPI
    private let walletLogic: WalletLogic
    private let operationsQueue: DispatchQueue

    init(
        walletRepo: WalletRepo,
        payloadCrypto: PayloadCryptoAPI,
        walletLogic: WalletLogic,
        operationsQueue: DispatchQueue
    ) {
        self.walletRepo = walletRepo
        self.payloadCrypto = payloadCrypto
        self.walletLogic = walletLogic
        self.operationsQueue = operationsQueue
    }

    func fetch(using password: String) -> AnyPublisher<EmptyValue, WalletError> {
        // 0. load the payload
        walletRepo
            .map(\.encryptedPayload)
            .first()
            .receive(on: operationsQueue)
            .flatMap { [payloadCrypto] payloadWrapper -> AnyPublisher<String, WalletError> in
                guard !payloadWrapper.payload.isEmpty else {
                    return .failure(WalletError.payloadNotFound)
                }
                // 1. decrypt the payload
                return payloadCrypto.decryptWallet(
                    walletWrapper: payloadWrapper,
                    password: password
                )
                .publisher
                .mapError { _ in WalletError.decryption(.decryptionError) }
                .eraseToAnyPublisher()
            }
            .flatMap { [walletLogic] string -> AnyPublisher<WalletState, WalletError> in
                guard let data = string.data(using: .utf8) else {
                    return .failure(.decryption(.decryptionError))
                }
                return walletLogic
                    .initialize(with: password, payload: data)
            }
            .flatMap { [walletRepo] walletState -> AnyPublisher<Wallet, WalletError> in
                storeSharedKey(from: walletState, on: walletRepo)
            }
            .map { _ in .noValue }
            .eraseToAnyPublisher()
        // 2. save the guid to metadata (metadata can get this from WalletRepo)
        // 3. load the metadata (lazy)
        // 4. Success (or failure)
    }

    func fetch(using password: String, secondPassword: String) -> AnyPublisher<EmptyValue, WalletError> {
        walletLogic.initialize(
            with: password,
            secondPassword: secondPassword
        )
        .flatMap { [walletRepo] walletState -> AnyPublisher<Wallet, WalletError> in
            storeSharedKey(from: walletState, on: walletRepo)
        }
        .map { _ in .noValue }
        .eraseToAnyPublisher()
    }

    // MARK: - Private
}

/// Stores the sharedKey to the given WalletRepo
/// - Parameters:
///   - walletState: A `WalletState` that contains a decrypted wallet to get the shared key from
///   - walletRepo: A `WalletRepo` which the sharedKey will be stored
/// - Returns: An `AnyPublisher<Wallet, WalletError>`
func storeSharedKey(from walletState: WalletState, on walletRepo: WalletRepo) -> AnyPublisher<Wallet, WalletError> {
    walletRepo
        .set(keyPath: \.credentials.sharedKey, value: walletState.wallet.sharedKey)
        .mapError()
        .map { _ in walletState.wallet }
        .eraseToAnyPublisher()
}
