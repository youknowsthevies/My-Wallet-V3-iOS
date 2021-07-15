// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import AuthenticationKit
import ComposableArchitecture
import DIKit
import ToolKit

public struct WelcomeEnvironment {

    let mainQueue: AnySchedulerOf<DispatchQueue>
    let pollingQueue: AnySchedulerOf<DispatchQueue>
    let recaptchaService: GoogleRecaptchaServiceAPI
    let authenticationService: AuthenticationServiceAPI
    let walletPairingDependencies: WalletPairingDependencies
    let analyticsRecorder: AnalyticsEventRecorderAPI
    let errorRecorder: ErrorRecording
    let buildVersionProvider: () -> String

    public init(mainQueue: AnySchedulerOf<DispatchQueue>,
                buildVersionProvider: @escaping () -> String,
                pollingQueue: AnySchedulerOf<DispatchQueue> = DispatchQueue(
                    label: "com.blockchain.AuthenticationEnvironmentPollingQueue",
                    qos: .utility
                ).eraseToAnyScheduler(),
                recaptchaService: GoogleRecaptchaServiceAPI = resolve(),
                authenticationService: AuthenticationServiceAPI = resolve(),
                walletPairingDependencies: WalletPairingDependencies = WalletPairingDependencies(),
                cacheSuite: CacheSuite = resolve(),
                analyticsRecorder: AnalyticsEventRecorderAPI = resolve(),
                errorRecorder: ErrorRecording = resolve()) {
        self.mainQueue = mainQueue
        self.pollingQueue = pollingQueue
        self.recaptchaService = recaptchaService
        self.authenticationService = authenticationService
        self.walletPairingDependencies = walletPairingDependencies
        self.analyticsRecorder = analyticsRecorder
        self.errorRecorder = errorRecorder
        self.buildVersionProvider = buildVersionProvider
    }
}

extension WelcomeEnvironment {

    public struct WalletPairingDependencies {

        // MARK: - Pairing dependencies

        let emailAuthorizationService: EmailAuthorizationServiceAPI
        let sessionTokenService: SessionTokenServiceAPI
        let smsService: SMSServiceAPI
        let loginService: LoginServiceAPI
        let walletFetcher: PairingWalletFetching

        /// TODO: Remove from dependencies
        let wallet: WalletAuthenticationKitWrapper

        public init(emailAuthorizationService: EmailAuthorizationServiceAPI = resolve(),
                    sessionTokenService: SessionTokenServiceAPI = resolve(),
                    smsService: SMSServiceAPI = resolve(),
                    loginService: LoginServiceAPI = resolve(),
                    walletFetcher: PairingWalletFetching = resolve(),
                    wallet: WalletAuthenticationKitWrapper = resolve()) {
            self.wallet = wallet
            self.walletFetcher = walletFetcher
            self.sessionTokenService = sessionTokenService
            self.smsService = smsService
            self.emailAuthorizationService = emailAuthorizationService
            self.loginService = loginService
        }
    }
}
