// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation
import KeychainKit
import ToolKit

public protocol WalletRepoPersistenceAPI {
    /// Begins the internal persist operation by monitor changes in the `WalletRepo`
    /// - Returns: A publisher of type `AnyPublisher<EmptyValue, WalletPersistenceError>`
    func beginPersisting() -> AnyPublisher<EmptyValue, WalletRepoPersistenceError>

    /// Retrieves the `WalletStorageState` from the `Keychain` as `AnyPublisher`
    /// - Returns: An `AnyPublisher<WalletRepoState, WalletPersistenceError>`
    func retrieve() -> AnyPublisher<WalletRepoState, WalletRepoPersistenceError>
}

public enum WalletRepoPersistenceError: Error, Equatable {
    case keychainFailure(KeychainAccessError)
    case decodingFailed(WalletRepoStateCodingError)
}

/// An object responsible for observing changes from `WalletStorage` and persisting them.
final class WalletRepoPersistence: WalletRepoPersistenceAPI {

    enum KeychainAccessKey {
        static let walletState = "wallet-repo-state"
    }

    private let repo: WalletRepo
    private let keychainAccess: KeychainAccessAPI
    private let persistenceQueue: DispatchQueue
    private let encoder: WalletRepoStateEncoding
    private let decoder: WalletRepoStateDecoding

    init(
        repo: WalletRepo,
        keychainAccess: KeychainAccessAPI,
        queue: DispatchQueue,
        encoder: @escaping WalletRepoStateEncoding = walletRepoStateEncoder,
        decoder: @escaping WalletRepoStateDecoding = walletRepoStateDecoder
    ) {
        self.repo = repo
        self.keychainAccess = keychainAccess
        self.encoder = encoder
        self.decoder = decoder
        persistenceQueue = queue
    }

    func beginPersisting() -> AnyPublisher<EmptyValue, WalletRepoPersistenceError> {
        repo
            .removeDuplicates()
            .setFailureType(to: WalletRepoPersistenceError.self)
            .receive(on: persistenceQueue)
            .flatMap { [encoder] state in
                encoder(state)
                    .publisher
                    .mapError(WalletRepoPersistenceError.decodingFailed)
            }
            .flatMap { [keychainAccess] data in
                keychainAccess
                    .write(value: data, for: KeychainAccessKey.walletState)
                    .publisher
                    .mapError(WalletRepoPersistenceError.keychainFailure)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    func retrieve() -> AnyPublisher<WalletRepoState, WalletRepoPersistenceError> {
        keychainAccess.read(for: KeychainAccessKey.walletState)
            .mapError(WalletRepoPersistenceError.keychainFailure)
            .publisher
            .receive(on: persistenceQueue)
            .flatMap { [decoder] data -> AnyPublisher<WalletRepoState, WalletRepoPersistenceError> in
                decoder(data)
                    .mapError(WalletRepoPersistenceError.decodingFailed)
                    .publisher
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}

// MARK: - Global Retrieval Method

/// Retrieves the `WalletStorageState` from the `Keychain`
/// - Returns: A previously stored `WalletStorageState` or an default empty state
func retrieveWalletRepoState(
    keychainAccess: KeychainAccessAPI,
    decoder: WalletRepoStateDecoding = walletRepoStateDecoder
) -> WalletRepoState? {
    let readResult = keychainAccess.read(for: WalletRepoPersistence.KeychainAccessKey.walletState)
    guard case .success(let data) = readResult else {
        return nil
    }
    guard case .success(let state) = decoder(data) else {
        return nil
    }
    return state
}
