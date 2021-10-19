// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import Combine
import DIKit
import FeatureSettingsDomain
import Localization
import PlatformKit
import RxRelay
import RxSwift
import ToolKit

/// This is a counterpart of `CreateWalletScreenInteractor` and it is added so that we be able to
/// use the old screens (soon to be replaced) with the new implementation of the welcome view in FeatureAuthenticationDomain
public final class CreateWalletInteractor: RegisterWalletScreenInteracting {

    // MARK: - Exposed Properties

    public let contentStateRelay = BehaviorRelay(value: WalletRegistrationContent())

    /// Any error related to the interaction should be reflected to the presenter
    /// Since the JS is async and callbacks oriented, we
    /// want to use a relay to let the presentation layer
    /// know about errors
    public let error: Observable<String>

    // MARK: - Private

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Injected

    private let reachability: InternetReachabilityAPI
    private let analyticsRecorder: AnalyticsEventRecorderAPI
    private let walletManager: WalletManagerAPI

    // MARK: - Setup

    public init(
        reachability: InternetReachabilityAPI = resolve(),
        analyticsRecorder: AnalyticsEventRecorderAPI = resolve(),
        walletManager: WalletManagerAPI = resolve()
    ) {
        self.analyticsRecorder = analyticsRecorder
        self.reachability = reachability
        self.walletManager = walletManager

        // Handle creation of new account

        let accountCreated = walletManager.didCreateNewAccount
            .shareReplay()

        // we're listening to the walletJSReady callback
        // capturing the latest from content, which contains password and email
        // we then request a new account from wallet.
        // The stream is killed once get a successful didCreateNewAccount callback
        walletManager.walletJSisReady
            .withLatestFrom(contentStateRelay.asPublisher()) { $1 }
            .prefix(untilOutputFrom: accountCreated.filter(\.isSuccess))
            .ignoreFailure()
            .sink(receiveValue: { content in
                walletManager.newWallet(password: content.password, email: content.email)
            })
            .store(in: &cancellables)

        error = accountCreated
            .filter(\.isFailure)
            .compactMap { value -> String? in
                guard case .failure(let error) = value else {
                    return LocalizationConstants.Errors.genericError
                }
                return error.localizedDescription
            }
            .asObservable()

        // we're listening for a successful `didCreateNewAccount`
        // the code in the observation below is taken from the `CreateWalletScreenInteractor`
        accountCreated
            .filter(\.isSuccess)
            .compactMap(\.successData)
            .sink(receiveValue: { [walletManager] walletCreation in
                /// Reset wallet + `JSContext`
                walletManager.forgetWallet()

                // Load the newly created wallet
                let guid = walletCreation.guid
                let sharedKey = walletCreation.sharedKey
                let password = walletCreation.password
                walletManager.load(with: guid, sharedKey: sharedKey, password: password)

                /// Mark the wallet as new
                walletManager.markWalletAsNew()

                BlockchainSettings.App.shared.hasEndedFirstSession = false
            })
            .store(in: &cancellables)
    }

    public func prepare() -> Result<Void, Error> {
        .success(())
    }

    public func execute() -> Result<Void, Error> {
        guard reachability.canConnect else {
            return .failure(InternetReachabilityError.internetUnreachable)
        }

        analyticsRecorder.record(events: [
            AnalyticsEvents.New.Onboarding.walletSignedUp
        ])

        walletManager.loadWalletJS()
        return .success(())
    }
}
