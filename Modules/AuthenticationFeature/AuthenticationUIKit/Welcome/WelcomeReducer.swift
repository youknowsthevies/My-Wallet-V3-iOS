// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AuthenticationKit
import ComposableArchitecture
import DIKit
import PlatformUIKit
import ToolKit

// MARK: - Type

public enum WelcomeAction: Equatable {
    case start
    case presentScreenFlow(WelcomeState.ScreenFlow)
    case emailLogin(EmailLoginAction)
    case deeplinkReceived(URL)
    case requestedToDecryptWallet(String)
    /// should only be used on internal builds
    case manualPairing(CredentialsAction)
    case secondPasswordNotice(SecondPasswordNotice.Action)
    case informSecondPasswordDetected
    case modalDismissed(WelcomeState.Modals)
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
        case manualLoginScreen
    }

    public enum Modals: Equatable {
        case secondPasswordNoticeScreen
        case none
    }

    public var screenFlow: ScreenFlow
    public var modals: Modals
    public var buildVersion: String
    var emailLoginState: EmailLoginState?

    var secondPasswordNoticeState: SecondPasswordNotice.State?

    /// should only be used on internal builds
    var manualCredentialsState: CredentialsState?
    var manualPairingEnabled: Bool

    public init() {
        emailLoginState = .init()
        manualCredentialsState = nil
        secondPasswordNoticeState = nil
        buildVersion = ""
        screenFlow = .welcomeScreen
        manualPairingEnabled = false
        modals = .none
    }
}

public struct WelcomeEnvironment {
    let mainQueue: AnySchedulerOf<DispatchQueue>
    let deviceVerificationService: DeviceVerificationServiceAPI
    let buildVersionProvider: () -> String
    let featureFlags: InternalFeatureFlagServiceAPI
    let errorRecorder: ErrorRecording
    let externalAppOpener: ExternalAppOpener

    public init(
        mainQueue: AnySchedulerOf<DispatchQueue>,
        deviceVerificationService: DeviceVerificationServiceAPI = resolve(),
        featureFlags: InternalFeatureFlagServiceAPI,
        buildVersionProvider: @escaping () -> String,
        errorRecorder: ErrorRecording = resolve(),
        externalAppOpener: ExternalAppOpener = resolve()
    ) {
        self.mainQueue = mainQueue
        self.deviceVerificationService = deviceVerificationService
        self.buildVersionProvider = buildVersionProvider
        self.featureFlags = featureFlags
        self.errorRecorder = errorRecorder
        self.externalAppOpener = externalAppOpener
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
    credentialsReducer
        .optional()
        .pullback(
            state: \.manualCredentialsState,
            action: /WelcomeAction.manualPairing,
            environment: {
                CredentialsEnvironment(
                    deviceVerificationService: $0.deviceVerificationService,
                    errorRecorder: $0.errorRecorder
                )
            }
        ),
    secondPasswordNoticeReducer
        .optional()
        .pullback(
            state: \.secondPasswordNoticeState,
            action: /WelcomeAction.secondPasswordNotice,
            environment: {
                SecondPasswordNotice.Environment(
                    externalAppOpener: $0.externalAppOpener
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
            #if INTERNAL_BUILD
            state.manualPairingEnabled = !environment.featureFlags.isEnabled(.disableGUIDLogin)
            #endif
            return .none
        case .presentScreenFlow(let screenFlow):
            state.screenFlow = screenFlow
            #if INTERNAL_BUILD
            if screenFlow == .manualLoginScreen {
                state.manualCredentialsState = .init()
            }
            #endif
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

        case .manualPairing(.walletPairing(.decryptWalletWithPassword(let password))):
            return Effect(value: .requestedToDecryptWallet(password))
        case .manualPairing(.closeButtonTapped),
             .manualPairing(.didDisappear):
            state.screenFlow = .welcomeScreen
            return .none
        case .manualPairing:
            return .none
        case .informSecondPasswordDetected:
            state.screenFlow = .welcomeScreen
            state.modals = .secondPasswordNoticeScreen
            state.secondPasswordNoticeState = .init()
            return .none
        case .secondPasswordNotice(.closeButtonTapped):
            state.screenFlow = .welcomeScreen
            state.modals = .none
            state.emailLoginState = .init()
            state.manualCredentialsState = nil
            state.secondPasswordNoticeState = nil
            return .none
        case .secondPasswordNotice:
            return .none
        case .modalDismissed(.secondPasswordNoticeScreen) where state.secondPasswordNoticeState != nil:
            state.screenFlow = .welcomeScreen
            state.modals = .none
            state.emailLoginState = .init()
            state.manualCredentialsState = nil
            state.secondPasswordNoticeState = nil
            return .none
        case .modalDismissed:
            return .none
        }
    }
)
