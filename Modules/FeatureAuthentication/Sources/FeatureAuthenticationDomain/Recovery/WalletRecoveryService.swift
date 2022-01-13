// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import ToolKit
import WalletPayloadKit

public struct WalletRecoveryService {
    public var recoverFromMetadata: (
        _ mnemonic: String
    ) -> AnyPublisher<EmptyValue, WalletError>

    public var recover: (
        _ email: String,
        _ password: String,
        _ mnemonic: String
    ) -> AnyPublisher<EmptyValue, WalletError>
}

extension WalletRecoveryService {
    public static func live(
        walletManager: WalletManagerAPI,
        walletRecovery: WalletRecoveryServiceAPI,
        nativeWalletEnabled: @escaping () -> AnyPublisher<Bool, Never>
    ) -> Self {
        Self(
            recoverFromMetadata: { [walletManager, walletRecovery, nativeWalletEnabled, legacyRecover] mnemonic in
                nativeWalletEnabled()
                    .flatMap { isEnabled -> AnyPublisher<EmptyValue, WalletError> in
                        guard isEnabled else {
                            return legacyRecover(mnemonic, walletManager)
                        }
                        return walletRecovery.recover(from: mnemonic)
                    }
                    .eraseToAnyPublisher()
            },
            recover: { [walletManager, nativeWalletEnabled, legacyImportWallet] email, password, mnemonic in
                nativeWalletEnabled()
                    .flatMap { isEnabled -> AnyPublisher<EmptyValue, WalletError> in
                        guard isEnabled else {
                            return legacyImportWallet(email, password, mnemonic, walletManager)
                        }
                        unimplemented("Importing a wallet is not yet available using Native Wallet")
                    }
                    .eraseToAnyPublisher()
            }
        )
    }

    public static var noop: Self {
        Self(
            recoverFromMetadata: { _ in .empty() },
            recover: { _, _, _ in .empty() }
        )
    }
}

private func legacyImportWallet(
    email: String,
    password: String,
    mnemonic: String,
    walletManager: WalletManagerAPI
) -> AnyPublisher<EmptyValue, WalletError> {
    walletManager.loadWalletJS()
    walletManager.recover(
        email: email,
        password: password,
        seedPhrase: mnemonic
    )
    return listenForRecoveryEvents(walletManager: walletManager)
}

private func legacyRecover(
    mnemonic: String,
    walletManager: WalletManagerAPI
) -> AnyPublisher<EmptyValue, WalletError> {
    walletManager.loadWalletJS()
    walletManager.recoverFromMetadata(
        seedPhrase: mnemonic
    )
    return listenForRecoveryEvents(walletManager: walletManager)
}

private func listenForRecoveryEvents(
    walletManager: WalletManagerAPI
) -> AnyPublisher<EmptyValue, WalletError> {
    let recovered = walletManager.walletRecovered
        .mapError { _ in WalletError.recovery(.failedToRecoverWallet) }
        .map { _ in EmptyValue.noValue }
        .eraseToAnyPublisher()

    // always fail upon receiving an event from `walletRecoveryFailed`
    let recoveryFailed = walletManager.walletRecoveryFailed
        .mapError { _ in WalletError.recovery(.failedToRecoverWallet) }
        .flatMap { _ -> AnyPublisher<EmptyValue, WalletError> in
            .failure(.recovery(.failedToRecoverWallet))
        }
        .eraseToAnyPublisher()

    return Publishers.Merge(recovered, recoveryFailed)
        .mapError { _ in WalletError.recovery(.failedToRecoverWallet) }
        .map { _ in .noValue }
        .eraseToAnyPublisher()
}
