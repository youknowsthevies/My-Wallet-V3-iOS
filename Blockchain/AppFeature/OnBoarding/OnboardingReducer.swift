// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import ComposableArchitecture
import PlatformUIKit
import SettingsKit

public enum Onboarding {
    public enum Action: Equatable {
        case start
        case pin(PinCore.Action)
        case passwordScreen
        case welcomeScreen
    }

    public struct State: Equatable {
        var pinState: PinCore.State? = .init()
    }

    public struct Environment {
        var blockchainSettings: BlockchainSettings.App
        var walletManager: WalletManager
        var alertPresenter: AlertViewPresenterAPI
    }
}

/// The reducer responsible for handing Pin screen and Login/Onboarding screen related action and state.
let onBoardingReducer = Reducer<Onboarding.State, Onboarding.Action, Onboarding.Environment>.combine(
    pinReducer
        .optional()
        .pullback(
            state: \.pinState,
            action: /Onboarding.Action.pin,
            environment: {
                PinCore.Environment(
                    walletManager: $0.walletManager,
                    appSettings: $0.blockchainSettings,
                    alertPresenter: $0.alertPresenter
                )
            }
        ),
    Reducer<Onboarding.State, Onboarding.Action, Onboarding.Environment> { _, action, environment in
        switch action {
        case .start:
            return decideFlow(
                blockchainSettings: environment.blockchainSettings
            )
        case .pin(.logout):
            // TODO: Handle logout logic
            return .none
        case .pin:
            return .none
        case .passwordScreen:
            return .none
        case .welcomeScreen:
            return .none
        }
    }
)


private func decideFlow(blockchainSettings: BlockchainSettings.App) -> Effect<Onboarding.Action, Never> {
    if blockchainSettings.guid != nil, blockchainSettings.sharedKey != nil {
        // Original flow
        if blockchainSettings.isPinSet {
            return Effect(value: .pin(.authenticate))
        } else {
            return Effect(value: .passwordScreen)
        }
    } else if blockchainSettings.pinKey != nil, blockchainSettings.encryptedPinPassword != nil {
        // iCloud restoration flow
        if blockchainSettings.isPinSet {
            return Effect(value: .pin(.authenticate))
        } else {
            return Effect(value: .passwordScreen)
        }
    } else {
        // on boarding == login
        return Effect(value: .welcomeScreen)
    }
}
