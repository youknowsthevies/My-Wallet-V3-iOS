// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import Foundation
import MetadataKit
import ToolKit

protocol WalletLogicAPI {
    /// Initialises a `Wallet` using the given payload data
    /// - Parameter password: A `String` value representing user's password
    /// - Parameter secondPassword: A `String` value representing user's second password
    /// - Returns: `AnyPublisher<WalletState, WalletError>`
    func initialize(
        with password: String,
        secondPassword: String
    ) -> AnyPublisher<WalletState, WalletError>

    /// Initialises a `Wallet` using the given payload data
    /// - Parameter payload: A `Data` value representing a valid decrypted wallet payload
    /// - Returns: `AnyPublisher<WalletState, WalletError>`
    func initialize(
        with password: String,
        payload: Data
    ) -> AnyPublisher<WalletState, WalletError>

    /// Initialises a `Wallet` from metadata using the given seed phrase
    /// - Parameter mnemonic: A `String` value representing the users mnemonic words
    /// - Returns: `AnyPublisher<WalletState, WalletError>`
    func initialize(
        with mnemonic: String
    ) -> AnyPublisher<MetadataRecoveryCredentials, WalletError>

    /// Initialises a `Wallet` after recovery using the given payload data
    /// - Parameter password: A `String` value representing user's password
    /// - Parameter payload: A `Data` value representing a valid decrypted wallet payload
    /// - Returns: `AnyPublisher<WalletState, WalletError>`
    func initializeAfterMetadataRecovery(
        with password: String,
        payload: Data
    ) -> AnyPublisher<WalletState, WalletError>
}

final class WalletLogic: WalletLogicAPI {

    private let holder: WalletHolderAPI
    private let decoder: WalletDecoding
    private let metadata: MetadataServiceAPI
    private let notificationCenter: NotificationCenter

    #warning("TODO: This should be removed, pass opaque context from initialize methods instead")
    private var tempPassword: String?

    init(
        holder: WalletHolderAPI,
        decoder: @escaping WalletDecoding,
        metadata: MetadataServiceAPI,
        notificationCenter: NotificationCenter
    ) {
        self.holder = holder
        self.decoder = decoder
        self.metadata = metadata
        self.notificationCenter = notificationCenter
    }

    func initialize(
        with password: String,
        secondPassword: String
    ) -> AnyPublisher<WalletState, WalletError> {
        holder.walletStatePublisher
            .flatMap { walletState -> AnyPublisher<WalletState, WalletError> in
                guard let walletState = walletState else {
                    return .failure(.payloadNotFound)
                }
                return .just(walletState)
            }
            .flatMap { walletState -> AnyPublisher<NativeWallet, WalletError> in
                guard let wallet = walletState.wallet else {
                    return .failure(.initialization(.missingWallet))
                }
                return .just(wallet)
            }
            .flatMap { [initialiseMetadataWithSecondPassword, tempPassword] wallet
                -> AnyPublisher<WalletState, WalletError> in
                guard let tempPassword = tempPassword else {
                    return .failure(.initialization(.unknown))
                }
                return initialiseMetadataWithSecondPassword(wallet, tempPassword, secondPassword)
            }
            .eraseToAnyPublisher()
    }

    func initialize(
        with password: String,
        payload: Data
    ) -> AnyPublisher<WalletState, WalletError> {
        decoder(payload)
            .flatMap { [holder] wallet -> AnyPublisher<NativeWallet?, WalletError> in
                holder.hold(walletState: .partially(loaded: .justWallet(wallet)))
                    .map(\.wallet)
                    .setFailureType(to: WalletError.self)
                    .eraseToAnyPublisher()
            }
            .flatMap { wallet -> AnyPublisher<NativeWallet, WalletError> in
                guard let wallet = wallet else {
                    return .failure(.initialization(.missingWallet))
                }
                return .just(wallet)
            }
            .flatMap { [initialiseMetadata] wallet -> AnyPublisher<WalletState, WalletError> in
                initialiseMetadata(wallet, password)
            }
            .eraseToAnyPublisher()
    }

    func initializeAfterMetadataRecovery(
        with password: String,
        payload: Data
    ) -> AnyPublisher<WalletState, WalletError> {
        holder.walletStatePublisher
            .first()
            .flatMap { walletState -> AnyPublisher<MetadataState, WalletError> in
                guard let metadataState = walletState?.metadata else {
                    return .failure(.initialization(.metadataInitialization))
                }
                return .just(metadataState)
            }
            .flatMap { [decoder] metadataState -> AnyPublisher<(NativeWallet, MetadataState), WalletError> in
                decoder(payload)
                    .map { ($0, metadataState) }
                    .eraseToAnyPublisher()
            }
            .flatMap { [holder] wallet, metadataState -> AnyPublisher<WalletState, WalletError> in
                holder.hold(walletState: .loaded(wallet: wallet, metadata: metadataState))
                    .first()
                    .mapError()
                    .eraseToAnyPublisher()
            }
            .handleEvents(receiveOutput: { [notifyReactiveWallet] _ in
                // inform ReactiveWallet that we're initialised
                notifyReactiveWallet()
            })
            .eraseToAnyPublisher()
    }

    func initialize(
        with mnemonic: String
    ) -> AnyPublisher<MetadataRecoveryCredentials, WalletError> {
        metadata.initializeAndRecoverCredentials(from: mnemonic)
            .mapError { _ in WalletError.initialization(.metadataInitialization) }
            .flatMap { [holder] context -> AnyPublisher<RecoveryContext, WalletError> in
                holder.hold(walletState: .partially(loaded: .justMetadata(context.metadataState)))
                    .setFailureType(to: WalletError.self)
                    .map { _ in context }
                    .first()
                    .eraseToAnyPublisher()
            }
            .map { context in
                MetadataRecoveryCredentials(
                    guid: context.guid,
                    sharedKey: context.sharedKey,
                    password: context.password
                )
            }
            .eraseToAnyPublisher()
    }

    // MARK: - Private

    private func initialiseMetadataWithSecondPassword(
        with wallet: NativeWallet,
        password: String,
        secondPassword: String
    ) -> AnyPublisher<WalletState, WalletError> {
        guard wallet.doubleEncrypted else {
            fatalError("This method should only be called if a secondPassword is needed")
        }
        return initialiseMetadata(with: wallet, password: password, secondPassword: secondPassword)
    }

    private func initialiseMetadata(
        with wallet: NativeWallet,
        password: String
    ) -> AnyPublisher<WalletState, WalletError> {
        if wallet.doubleEncrypted {
            tempPassword = password
            return .failure(.initialization(.needsSecondPassword))
        }
        return initialiseMetadata(with: wallet, password: password, secondPassword: nil)
    }

    private func initialiseMetadata(
        with wallet: NativeWallet,
        password: String,
        secondPassword: String?
    ) -> AnyPublisher<WalletState, WalletError> {
        provideMetadataInput(
            password: password,
            secondPassword: secondPassword,
            wallet: wallet
        )
        .map { input in
            (input, wallet)
        }
        .flatMap { [metadata] input, wallet -> AnyPublisher<WalletState, WalletError> in
            metadata.initialize(
                credentials: input.credentials,
                masterKey: input.masterKey,
                payloadIsDoubleEncrypted: input.payloadIsDoubleEncrypted
            )
            .map { metadataState -> WalletState in
                .loaded(wallet: wallet, metadata: metadataState)
            }
            .replaceError(with: .initialization(.metadataInitialization))
            .eraseToAnyPublisher()
        }
        .flatMap { [holder] walletState
            -> AnyPublisher<WalletState, WalletError> in
            holder.hold(walletState: walletState)
                .setFailureType(to: WalletError.self)
                .eraseToAnyPublisher()
        }
        .handleEvents(receiveOutput: { [notifyReactiveWallet] _ in
            // inform ReactiveWallet that we're initialised
            notifyReactiveWallet()
        })
        .eraseToAnyPublisher()
    }

    private func notifyReactiveWallet() {
        notificationCenter.post(Notification(name: .walletInitialized))
        notificationCenter.post(Notification(name: .walletMetadataLoaded))
    }
}

struct MetadataInput {
    let credentials: Credentials
    let masterKey: MasterKey
    let payloadIsDoubleEncrypted: Bool
}

func provideMetadataInput(
    password: String,
    secondPassword: String?,
    wallet: NativeWallet
) -> AnyPublisher<MetadataInput, WalletError> {
    getSeedHex(from: wallet, secondPassword: secondPassword)
        .flatMap(masterKeyFrom(seedHex:))
        .map { masterKey -> MetadataInput in
            let credentials = Credentials(
                guid: wallet.guid,
                sharedKey: wallet.sharedKey,
                password: password
            )
            return MetadataInput(
                credentials: credentials,
                masterKey: masterKey,
                payloadIsDoubleEncrypted: wallet.doubleEncrypted
            )
        }
        .publisher
        .eraseToAnyPublisher()
}

private func masterKeyFrom(seedHex: String) -> Result<MasterKey, WalletError> {
    MasterKey.from(seedHex: seedHex)
        .mapError { _ -> WalletError in
            .initialization(.metadataInitialization)
        }
}
