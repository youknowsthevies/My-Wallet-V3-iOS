// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import ComposableArchitecture
import PlatformKit
import PlatformUIKit
import SettingsKit

public enum PinCore {
    public enum Action: Equatable {
        /// Displays the Pin screen for authentication
        case authenticate
        /// Displays the Pin screen for creating a pin
        case create
        /// Displays the Pin screen for changing the current pin
        case change
        /// Performs a logout
        case logout
        /// Sent by the pin screen to perform wallet authentication
        case handleAuthentication(_ password: String)
        /// Wallet related actions
        case didDecryptWallet(WalletDecryption)
        case decryptionFailure(AuthenticationError)
        case authenticated(Result<Bool, AuthenticationError>)
        case none
    }

    public struct State: Equatable {
        var changing: Bool = false
        var creating: Bool = false
        var authenticate: Bool = false
    }

    public struct Environment {
        let walletManager: WalletManager
        let appSettings: BlockchainSettings.App
        let alertPresenter: AlertViewPresenterAPI
    }
}

let pinReducer = Reducer<PinCore.State, PinCore.Action, PinCore.Environment> { state, action, environment in
    switch action {
    case .authenticate:
        state.creating = false
        state.authenticate = true
        return .none
    case .create:
        state.creating = true
        state.authenticate = false
        return .none
    case .change:
        state.creating = false
        state.authenticate = false
        state.changing = true
        return .none
    case .logout:
        return .none
    case .handleAuthentication(let password):
        environment.walletManager.wallet.fetch(with: password)
        let appSettings = environment.appSettings
        return .merge(
            environment.walletManager.didDecryptWallet
                .catchToEffect()
                .map { result -> PinCore.Action in
                    guard case let .success(value) = result else {
                        return .none
                    }
                    return handleWalletDecryption(decryption: value)
                },
            environment.walletManager.didCompleteAuthentication
                .catchToEffect()
                .map { result -> PinCore.Action in
                    guard case let .success(value) = result else {
                        return PinCore.Action.authenticated(
                            .failure(.init(code: AuthenticationError.ErrorCode.unknown.rawValue))
                        )
                    }
                    return PinCore.Action.authenticated(value)
                }
        )
    case .didDecryptWallet(let decryption):
        environment.appSettings.guid = decryption.guid
        environment.appSettings.sharedKey = decryption.sharedKey
        return .fireAndForget {
            clearPinIfNeeded(
                for: decryption.passwordPartHash,
                appSettings: environment.appSettings
            )
        }
    case .decryptionFailure(let error):
        return .none
    case .authenticated(.success):
        return .none
    case .authenticated(.failure(let error)):
        // TODO: Handle authentication error
        return .none
    case .none:
        return .none
    }
}

// MARK: Private methods

private func handleWalletDecryption(decryption: WalletDecryption) -> PinCore.Action {

    //// Verify valid GUID and sharedKey
    guard let guid = decryption.guid, guid.count == 36 else {
        return .decryptionFailure(
            AuthenticationError(
                code: AuthenticationError.ErrorCode.errorDecryptingWallet.rawValue,
                description: LocalizationConstants.Authentication.errorDecryptingWallet
            )
        )
    }

    guard let sharedKey = decryption.sharedKey, sharedKey.count == 36 else {
        return .decryptionFailure(
            AuthenticationError(
                code: AuthenticationError.ErrorCode.invalidSharedKey.rawValue,
                description: LocalizationConstants.Authentication.invalidSharedKey
            )
        )
    }

    return .didDecryptWallet(decryption)
}

private func clearPinIfNeeded(for passwordPartHash: String?, appSettings: BlockchainSettings.App) {
    // Because we are not storing the password on the device. We record the first few letters of the hashed password.
    // With the hash prefix we can then figure out if the password changed. If so, clear the pin
    // so that the user can reset it
    guard let passwordPartHash = passwordPartHash,
          let savedPasswordPartHash = appSettings.passwordPartHash else {
        return
    }

    guard passwordPartHash != savedPasswordPartHash else {
        return
    }

    appSettings.clearPin()
}
