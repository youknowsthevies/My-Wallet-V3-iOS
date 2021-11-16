// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import Combine
import ComposableArchitecture
import DIKit
import FeatureAuthenticationDomain
import ToolKit

// MARK: - Type

public enum WelcomeAction: Equatable {
    case start
    case presentScreenFlow(WelcomeState.ScreenFlow)
    case createWallet(CreateAccountAction)
    case emailLogin(EmailLoginAction)
    case restoreWallet(SeedPhraseAction)
    case deeplinkReceived(URL)
    case requestedToDecryptWallet(String)
    case requestedToRestoreWallet(WalletRecovery)
    /// should only be used on internal builds
    case setManualPairingEnabled
    case manualPairing(CredentialsAction)
    case secondPasswordNotice(SecondPasswordNotice.Action)
    case informSecondPasswordDetected
    case modalDismissed(WelcomeState.Modals)
    case none
}

// MARK: - Properties

/// The `master` `State` for the Single Sign On (SSO) Flow
public struct WelcomeState: Equatable {
    public enum ScreenFlow {
        case welcomeScreen
        case createScreen
        case createWalletScreen
        case newCreateWalletScreen
        case emailLoginScreen
        case restoreWalletScreen
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
    public var createWalletState: CreateAccountState?
    public var emailLoginState: EmailLoginState?
    public var restoreWalletState: SeedPhraseState?

    public var secondPasswordNoticeState: SecondPasswordNotice.State?

    /// should only be used on internal builds
    var manualCredentialsState: CredentialsState?
    var manualPairingEnabled: Bool

    public init() {
        createWalletState = nil
        restoreWalletState = nil
        emailLoginState = nil
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
    let sessionTokenService: SessionTokenServiceAPI
    let deviceVerificationService: DeviceVerificationServiceAPI
    let buildVersionProvider: () -> String
    let featureFlagsService: FeatureFlagsServiceAPI
    let errorRecorder: ErrorRecording
    let externalAppOpener: ExternalAppOpener
    let analyticsRecorder: AnalyticsEventRecorderAPI

    public init(
        mainQueue: AnySchedulerOf<DispatchQueue>,
        sessionTokenService: SessionTokenServiceAPI = resolve(),
        deviceVerificationService: DeviceVerificationServiceAPI,
        featureFlagsService: FeatureFlagsServiceAPI,
        buildVersionProvider: @escaping () -> String,
        errorRecorder: ErrorRecording = resolve(),
        externalAppOpener: ExternalAppOpener = resolve(),
        analyticsRecorder: AnalyticsEventRecorderAPI = resolve()
    ) {
        self.mainQueue = mainQueue
        self.sessionTokenService = sessionTokenService
        self.deviceVerificationService = deviceVerificationService
        self.buildVersionProvider = buildVersionProvider
        self.featureFlagsService = featureFlagsService
        self.errorRecorder = errorRecorder
        self.externalAppOpener = externalAppOpener
        self.analyticsRecorder = analyticsRecorder
    }
}

public let welcomeReducer = Reducer.combine(
    createAccountReducer
        .optional()
        .pullback(
            state: \.createWalletState,
            action: /WelcomeAction.createWallet,
            environment: {
                CreateAccountEnvironment(
                    mainQueue: $0.mainQueue,
                    externalAppOpener: $0.externalAppOpener,
                    analyticsRecorder: $0.analyticsRecorder
                )
            }
        ),
    emailLoginReducer
        .optional()
        .pullback(
            state: \.emailLoginState,
            action: /WelcomeAction.emailLogin,
            environment: {
                EmailLoginEnvironment(
                    mainQueue: $0.mainQueue,
                    sessionTokenService: $0.sessionTokenService,
                    deviceVerificationService: $0.deviceVerificationService,
                    featureFlagsService: $0.featureFlagsService,
                    errorRecorder: $0.errorRecorder,
                    analyticsRecorder: $0.analyticsRecorder
                )
            }
        ),
    seedPhraseReducer
        .optional()
        .pullback(
            state: \.restoreWalletState,
            action: /WelcomeAction.restoreWallet,
            environment: {
                SeedPhraseEnvironment(
                    mainQueue: $0.mainQueue,
                    externalAppOpener: $0.externalAppOpener,
                    analyticsRecorder: $0.analyticsRecorder
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
                    mainQueue: $0.mainQueue,
                    deviceVerificationService: $0.deviceVerificationService,
                    errorRecorder: $0.errorRecorder,
                    featureFlagsService: $0.featureFlagsService,
                    analyticsRecorder: $0.analyticsRecorder
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
            // swiftlint:disable closure_body_length
    > { state, action, environment in
        switch action {

        case .start:
            state.buildVersion = environment.buildVersionProvider()
            if BuildFlag.isInternal {
                return environment
                    .featureFlagsService
                    .isEnabled(.local(.disableGUIDLogin))
                    .flatMap { isEnabled -> Effect<WelcomeAction, Never> in
                        guard !isEnabled else {
                            return .none
                        }
                        return Effect(value: .setManualPairingEnabled)
                    }
                    .eraseToEffect()
            }
            return .none

        case .setManualPairingEnabled:
            state.manualPairingEnabled = true
            return .none

        case .presentScreenFlow(let screenFlow):
            state.screenFlow = screenFlow
            switch screenFlow {
            case .createScreen:
                return environment
                    .featureFlagsService
                    .isEnabled(.local(.newCreateWalletScreen))
                    .receive(on: environment.mainQueue)
                    .catchToEffect()
                    .map { result -> WelcomeAction in
                        guard case .success(let isEnabled) = result else {
                            return .none
                        }
                        switch isEnabled {
                        case true:
                            return .presentScreenFlow(.newCreateWalletScreen)
                        case false:
                            return .presentScreenFlow(.createWalletScreen)
                        }
                    }
            case .newCreateWalletScreen:
                state.createWalletState = .init()
            case .emailLoginScreen:
                state.emailLoginState = .init()
            case .restoreWalletScreen:
                state.restoreWalletState = .init()
            case .welcomeScreen, .createWalletScreen, .manualLoginScreen:
                state.emailLoginState = nil
                state.restoreWalletState = nil
            }
            if BuildFlag.isInternal, screenFlow == .manualLoginScreen {
                state.manualCredentialsState = .init()
            }
            return .none

        case .deeplinkReceived(let url):
            // handle deeplink if we've entered verify device flow
            guard let loginState = state.emailLoginState,
                  loginState.verifyDeviceState != nil
            else {
                return .none
            }
            return Effect(value: .emailLogin(.verifyDevice(.didReceiveWalletInfoDeeplink(url))))

        case .requestedToDecryptWallet,
             .requestedToRestoreWallet:
            // handled in core coordinator
            return .none

        case .createWallet(.closeButtonTapped):
            state.screenFlow = .welcomeScreen
            state.createWalletState = nil
            return .none

        case .createWallet:
            return .none

        case .emailLogin(.closeButtonTapped):
            state.screenFlow = .welcomeScreen
            state.emailLoginState = nil
            return .none

        // TODO: refactor this by not relying on access lower level reducers
        case .emailLogin(.verifyDevice(.credentials(.walletPairing(.decryptWalletWithPassword(let password))))),
             .emailLogin(.verifyDevice(.upgradeAccount(.skipUpgrade(.credentials(.walletPairing(.decryptWalletWithPassword(let password))))))):
            return Effect(value: .requestedToDecryptWallet(password))

        case .emailLogin(.verifyDevice(.credentials(.seedPhrase(.restoreWallet(let walletRecovery))))):
            return Effect(value: .requestedToRestoreWallet(walletRecovery))

        case .restoreWallet(.restoreWallet(let walletRecovery)):
            return Effect(value: .requestedToRestoreWallet(walletRecovery))

        case .emailLogin:
            // handled in email login reducer
            return .none

        case .manualPairing(.walletPairing(.decryptWalletWithPassword(let password))):
            return Effect(value: .requestedToDecryptWallet(password))

        case .manualPairing(.closeButtonTapped):
            state.screenFlow = .welcomeScreen
            return .none

        case .manualPairing:
            return .none

        case .restoreWallet(.closeButtonTapped):
            state.screenFlow = .welcomeScreen
            state.restoreWalletState = .init()
            return .none

        case .restoreWallet:
            return .none

        case .informSecondPasswordDetected:
            state.screenFlow = .welcomeScreen
            state.modals = .secondPasswordNoticeScreen
            state.secondPasswordNoticeState = .init()
            return .none

        case .secondPasswordNotice(.closeButtonTapped):
            state.screenFlow = .welcomeScreen
            state.modals = .none
            state.emailLoginState = nil
            state.manualCredentialsState = nil
            state.secondPasswordNoticeState = nil
            return .none

        case .secondPasswordNotice:
            return .none

        case .modalDismissed(.secondPasswordNoticeScreen) where state.secondPasswordNoticeState != nil:
            state.screenFlow = .welcomeScreen
            state.modals = .none
            state.emailLoginState = nil
            state.manualCredentialsState = nil
            state.secondPasswordNoticeState = nil
            return .none

        case .modalDismissed:
            return .none

        case .none:
            return .none
        }
    }
)
.analytics()

extension Reducer where
    Action == WelcomeAction,
    State == WelcomeState,
    Environment == WelcomeEnvironment
{
    func analytics() -> Self {
        combined(
            with: Reducer<
                WelcomeState,
                WelcomeAction,
                WelcomeEnvironment
            > { _, action, environment in
                switch action {
                case .presentScreenFlow(.emailLoginScreen):
                    environment.analyticsRecorder.record(
                        event: .loginClicked()
                    )
                    return .none
                case .presentScreenFlow(.restoreWalletScreen):
                    environment.analyticsRecorder.record(
                        event: .recoveryOptionSelected
                    )
                    return .none
                default:
                    return .none
                }
            }
        )
    }
}
