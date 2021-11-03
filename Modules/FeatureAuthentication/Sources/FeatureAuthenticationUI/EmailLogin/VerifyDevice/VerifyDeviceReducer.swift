// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import Combine
import ComposableArchitecture
import ComposableNavigation
import DIKit
import FeatureAuthenticationDomain
import Localization
import ToolKit

// MARK: - Type

public enum VerifyDeviceAction: Equatable, NavigationAction {

    // MARK: - Alert

    public enum AlertAction: Equatable {
        case show(title: String, message: String)
        case dismiss
    }

    case alert(AlertAction)

    // MARK: - Navigation

    case onAppear
    case onWillDisappear
    case route(RouteIntent<VerifyDeviceRoute>?)

    // MARK: - Deeplink handling

    case didReceiveWalletInfoDeeplink(URL)
    case didExtractWalletInfo(WalletInfo)
    case fallbackToWalletIdentifier

    // MARK: - WalletInfo polling

    case pollWalletInfo

    // MARK: - Device Verification

    case openMailApp
    case sendDeviceVerificationEmail

    // MARK: - Local Actions

    case credentials(CredentialsAction)
    case upgradeAccount(UpgradeAccountAction)

    // MARK: - Utils

    case none
}

private enum VerifyDeviceCancellations {
    struct WalletInfoPollingId: Hashable {}
}

// MARK: - Properties

public struct VerifyDeviceState: Equatable, NavigationState {

    // MARK: - Navigation State

    public var route: RouteIntent<VerifyDeviceRoute>?

    // MARK: - Alert State

    var alert: AlertState<VerifyDeviceAction>?

    // MARK: - Credentials

    var emailAddress: String
    var credentialsContext: CredentialsContext

    // MARK: - Loading State

    var sendEmailButtonIsLoading: Bool

    // MARK: - Local States

    var credentialsState: CredentialsState?
    var upgradeAccountState: UpgradeAccountState?

    init(emailAddress: String) {
        self.emailAddress = emailAddress
        credentialsContext = .none
        sendEmailButtonIsLoading = false
    }
}

struct VerifyDeviceEnvironment {
    let mainQueue: AnySchedulerOf<DispatchQueue>
    let deviceVerificationService: DeviceVerificationServiceAPI
    let featureFlags: InternalFeatureFlagServiceAPI
    let appFeatureConfigurator: FeatureConfiguratorAPI
    let errorRecorder: ErrorRecording
    let externalAppOpener: ExternalAppOpener
    let analyticsRecorder: AnalyticsEventRecorderAPI

    init(
        mainQueue: AnySchedulerOf<DispatchQueue>,
        deviceVerificationService: DeviceVerificationServiceAPI,
        featureFlags: InternalFeatureFlagServiceAPI,
        appFeatureConfigurator: FeatureConfiguratorAPI,
        errorRecorder: ErrorRecording,
        externalAppOpener: ExternalAppOpener = resolve(),
        analyticsRecorder: AnalyticsEventRecorderAPI
    ) {
        self.mainQueue = mainQueue
        self.deviceVerificationService = deviceVerificationService
        self.featureFlags = featureFlags
        self.appFeatureConfigurator = appFeatureConfigurator
        self.errorRecorder = errorRecorder
        self.externalAppOpener = externalAppOpener
        self.analyticsRecorder = analyticsRecorder
    }
}

let verifyDeviceReducer = Reducer.combine(
    credentialsReducer
        .optional()
        .pullback(
            state: \.credentialsState,
            action: /VerifyDeviceAction.credentials,
            environment: {
                CredentialsEnvironment(
                    mainQueue: $0.mainQueue,
                    deviceVerificationService: $0.deviceVerificationService,
                    errorRecorder: $0.errorRecorder,
                    externalAppOpener: $0.externalAppOpener,
                    appFeatureConfigurator: $0.appFeatureConfigurator,
                    analyticsRecorder: $0.analyticsRecorder
                )
            }
        ),
    upgradeAccountReducer
        .optional()
        .pullback(
            state: \.upgradeAccountState,
            action: /VerifyDeviceAction.upgradeAccount,
            environment: {
                UpgradeAccountEnvironment(
                    mainQueue: $0.mainQueue,
                    deviceVerificationService: $0.deviceVerificationService,
                    errorRecorder: $0.errorRecorder,
                    appFeatureConfigurator: $0.appFeatureConfigurator,
                    analyticsRecorder: $0.analyticsRecorder
                )
            }
        ),
    Reducer<
        VerifyDeviceState,
        VerifyDeviceAction,
        VerifyDeviceEnvironment
            // swiftlint:disable closure_body_length
    > { state, action, environment in
        switch action {

        // MARK: - Alert

        case .alert(.show(let title, let message)):
            state.alert = AlertState(
                title: TextState(verbatim: title),
                message: TextState(verbatim: message),
                dismissButton: .default(
                    TextState(LocalizationConstants.okString),
                    action: .send(.alert(.dismiss))
                )
            )
            return .none

        case .alert(.dismiss):
            state.alert = nil
            return .none

        // MARK: - Navigations

        case .onAppear:
            if environment.featureFlags.isEnabled(.pollingForEmailLogin) {
                return Effect(value: .pollWalletInfo)
            } else {
                return .none
            }

        case .onWillDisappear:
            return .cancel(id: VerifyDeviceCancellations.WalletInfoPollingId())

        case .route(let route):
            if let routeValue = route?.route {
                switch routeValue {
                case .credentials:
                    switch state.credentialsContext {
                    case .walletInfo(let walletInfo):
                        state.credentialsState = CredentialsState(
                            walletPairingState: WalletPairingState(
                                emailAddress: walletInfo.email ?? "",
                                emailCode: walletInfo.emailCode,
                                walletGuid: walletInfo.guid
                            )
                        )
                    case .walletIdentifier(let guid):
                        state.credentialsState = CredentialsState(
                            walletPairingState: WalletPairingState(
                                walletGuid: guid ?? ""
                            )
                        )
                    case .manualPairing, .none:
                        state.credentialsState = .init()
                    }
                case .upgradeAccount:
                    guard case .walletInfo(let info) = state.credentialsContext else {
                        state.route = nil
                        return .none
                    }
                    state.upgradeAccountState = .init(walletInfo: info)
                }
            } else {
                state.credentialsState = nil
                state.upgradeAccountState = nil
            }
            state.route = route
            return .none

        // MARK: - Deeplink handling

        case .didReceiveWalletInfoDeeplink(let url):
            return environment
                .deviceVerificationService
                .extractWalletInfoFromDeeplink(url: url)
                .receive(on: environment.mainQueue)
                .catchToEffect()
                .map { result -> VerifyDeviceAction in
                    switch result {
                    case .success(let walletInfo):
                        return .didExtractWalletInfo(walletInfo)
                    case .failure(let error):
                        environment.errorRecorder.error(error)
                        switch error {
                        case .failToDecodeBase64Component,
                             .failToDecodeToWalletInfo:
                            return .fallbackToWalletIdentifier
                        }
                    }
                }

        case .didExtractWalletInfo(let walletInfo):
            guard walletInfo.email != nil, walletInfo.emailCode != nil else {
                state.credentialsContext = .walletIdentifier(guid: walletInfo.guid)
                // cancel the polling once wallet info is extracted
                // it could be from the deeplink or from the polling
                return .merge(
                    .cancel(id: VerifyDeviceCancellations.WalletInfoPollingId()),
                    .navigate(to: .credentials)
                )
            }
            state.credentialsContext = .walletInfo(walletInfo)
            return .merge(
                .cancel(id: VerifyDeviceCancellations.WalletInfoPollingId()),
                .navigate(to: .credentials)
            )

        case .fallbackToWalletIdentifier:
            state.credentialsContext = .walletIdentifier(guid: "")
            return Effect(value: .navigate(to: .credentials))

        // MARK: - WalletInfo polling

        case .pollWalletInfo:
            return environment
                .deviceVerificationService
                .pollForWalletInfo()
                .receive(on: environment.mainQueue)
                .catchToEffect()
                .cancellable(id: VerifyDeviceCancellations.WalletInfoPollingId())
                .map { result -> VerifyDeviceAction in
                    // extract wallet info once the polling endpoint receives a value
                    guard case .success(let walletInfo) = result else {
                        return .none
                    }
                    return .didExtractWalletInfo(walletInfo)
                }

        // MARK: - Device Verification

        case .sendDeviceVerificationEmail:
            // handled in email login reducer
            return .none

        case .openMailApp:
            environment
                .externalAppOpener
                .openMailApp { _ in }
            return .none

        // MARK: - Local Reducers

        case .credentials:
            // handled in credentials reducer
            return .none

        case .upgradeAccount:
            // handled in upgrade account reducer
            return .none

        // MARK: - Utils

        case .none:
            return .none
        }
    }
)
.analytics()

// MARK: - Private

extension Reducer where
    Action == VerifyDeviceAction,
    State == VerifyDeviceState,
    Environment == VerifyDeviceEnvironment
{
    /// Helper reducer for analytics tracking
    fileprivate func analytics() -> Self {
        combined(
            with: Reducer<
                VerifyDeviceState,
                VerifyDeviceAction,
                VerifyDeviceEnvironment
            > { _, action, environment in
                switch action {
                case .didExtractWalletInfo(let walletInfo):
                    environment.analyticsRecorder.record(
                        event: .deviceVerified(info: walletInfo)
                    )
                    return .none
                default:
                    return .none
                }
            }
        )
    }
}
