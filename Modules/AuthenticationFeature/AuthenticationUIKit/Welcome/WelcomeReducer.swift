// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AuthenticationKit
import ComposableArchitecture
import DIKit
import ToolKit

// MARK: - Type

public enum WelcomeAction: Equatable {
    case start
    case presentScreenFlow(WelcomeState.ScreenFlow)
    case emailLogin(EmailLoginAction)
    /// should only be used on internal builds
    case manualPairing(ManualPairing.Action)
}

// MARK: - Properties

/// The `master` `State` for the Single Sign On (SSO) Flow
public struct WelcomeState: Equatable {
    public enum ScreenFlow {
        case welcomeScreen
        case createWalletScreen
        case emailLoginScreen
        case recoverWalletScreen
        /// this should only be used for internal builds
        case guidLoginScreen
    }

    public var screenFlow: ScreenFlow
    public var buildVersion: String
    var emailLoginState: EmailLoginState?

    /// should only be used on internal builds
    var manualPairingState: ManualPairing.State?
    var manualPairingEnabled: Bool

    public init() {
        emailLoginState = .init()
        manualPairingState = nil
        buildVersion = ""
        screenFlow = .welcomeScreen
        manualPairingEnabled = false
    }
}

public struct WelcomeEnvironment {
    let mainQueue: AnySchedulerOf<DispatchQueue>
    let deviceVerificationService: DeviceVerificationServiceAPI
    let buildVersionProvider: () -> String
    let featureFlags: InternalFeatureFlagServiceAPI

    public init(
        mainQueue: AnySchedulerOf<DispatchQueue>,
        deviceVerificationService: DeviceVerificationServiceAPI = resolve(),
        featureFlags: InternalFeatureFlagServiceAPI,
        buildVersionProvider: @escaping () -> String
    ) {
        self.mainQueue = mainQueue
        self.deviceVerificationService = deviceVerificationService
        self.buildVersionProvider = buildVersionProvider
        self.featureFlags = featureFlags
    }
}

public let welcomeReducer = Reducer.combine(
    emailLoginReducer
        .optional()
        .pullback(
            state: \.emailLoginState,
            action: /WelcomeAction.emailLogin,
            environment: {
                EmailLoginEnvironment(
                    deviceVerificationService: $0.deviceVerificationService,
                    mainQueue: $0.mainQueue
                )
            }
        ),
    manualPairingReducer
        .optional()
        .pullback(
            state: \.manualPairingState,
            action: /WelcomeAction.manualPairing,
            environment: { _ in ManualPairing.Environment() }
        ),
    Reducer<
        WelcomeState,
        WelcomeAction,
        WelcomeEnvironment
    > { state, action, environment in
        switch action {
        case .start:
            state.buildVersion = environment.buildVersionProvider()
            #if INTERNAL_BUILD
            state.manualPairingEnabled = !environment.featureFlags.isEnabled(.disableGUIDLogin)
            #endif
            return .none
        case .presentScreenFlow(let screenFlow):
            state.screenFlow = screenFlow
            #if INTERNAL_BUILD
            if screenFlow == .guidLoginScreen {
                state.manualPairingState = .init()
            }
            #endif
            return .none
        case .emailLogin(.closeButtonTapped):
            state.screenFlow = .welcomeScreen
            state.emailLoginState = .init()
            return .none
        case .emailLogin:
            // handled in email login reducer
            return .none
        case .manualPairing(.closeButtonTapped):
            state.screenFlow = .welcomeScreen
            state.manualPairingState = nil
            return .none
        case .manualPairing:
            return .none
        }
    }
)
