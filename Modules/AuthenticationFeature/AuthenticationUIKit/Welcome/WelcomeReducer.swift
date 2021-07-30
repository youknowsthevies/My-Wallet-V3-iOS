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
    case deeplinkReceived(URL)
    case requestedToDecryptWallet(String)
}

// MARK: - Properties

/// The `master` `State` for the Single Sign On (SSO) Flow
public struct WelcomeState: Equatable {
    public enum ScreenFlow {
        case welcomeScreen
        case createWalletScreen
        case emailLoginScreen
        case recoverWalletScreen
    }

    public var screenFlow: ScreenFlow
    public var buildVersion: String
    var emailLoginState: EmailLoginState?

    public init() {
        emailLoginState = .init()
        buildVersion = ""
        screenFlow = .welcomeScreen
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
    Reducer<
        WelcomeState,
        WelcomeAction,
        WelcomeEnvironment
    > { state, action, environment in
        switch action {
        case .start:
            state.buildVersion = environment.buildVersionProvider()
            return .none
        case .presentScreenFlow(let screenFlow):
            state.screenFlow = screenFlow
            return .none
        case .deeplinkReceived(let url):
            // we currently only support deeplink if we're on the verify device screen
            guard let loginState = state.emailLoginState,
                  loginState.verifyDeviceState != nil
            else {
                return .none
            }
            return Effect(value: .emailLogin(.verifyDevice(.didReceiveWalletInfoDeeplink(url))))
        case .requestedToDecryptWallet(let password):
            // handled in core coordinator
            return .none
        case .emailLogin(.closeButtonTapped),
             .emailLogin(.didDisappear):
            state.screenFlow = .welcomeScreen
            state.emailLoginState = .init()
            return .none
        case .emailLogin(.verifyDevice(.credentials(.walletPairing(.decryptWalletWithPassword(let password))))):
            return Effect(value: .requestedToDecryptWallet(password))
        case .emailLogin:
            // handled in email login reducer
            return .none
        }
    }
)
