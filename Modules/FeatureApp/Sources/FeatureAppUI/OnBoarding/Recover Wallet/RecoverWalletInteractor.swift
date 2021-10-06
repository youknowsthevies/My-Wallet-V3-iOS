// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import AnalyticsKit
import DIKit
import PlatformKit
import RxRelay
import RxSwift
import ToolKit

/// This is a counterpart of `RecoverWalletScreenInteractor` and it is added so that we be able to
/// use the old screens (soon to be replaced) with the new implementation of the welcome view in FeatureAuthenticationDomain
public final class RecoverWalletInteractor: RegisterWalletScreenInteracting {

    // MARK: - Exposed Properties

    public let contentStateRelay = BehaviorRelay(value: WalletRegistrationContent())
    var content: Observable<WalletRegistrationContent> {
        contentStateRelay.asObservable()
    }

    /// Reflects errors received from the JS layer
    public var error: Observable<String> = .empty()

    // MARK: - Injected

    private let reachability: InternetReachabilityAPI
    private let analyticsRecorder: AnalyticsEventRecorderAPI
    private let walletManager: WalletManagerAPI

    /// A passphrase for recovery
    private let passphrase: String

    // MARK: - Accessors

    // MARK: - Setup

    public init(
        passphrase: String,
        analyticsRecorder: AnalyticsEventRecorderAPI = resolve(),
        reachability: InternetReachabilityAPI = resolve(),
        walletManager: WalletManagerAPI = resolve()
    ) {
        self.passphrase = passphrase
        self.analyticsRecorder = analyticsRecorder
        self.reachability = reachability
        self.walletManager = walletManager
    }

    public func prepare() -> Result<Void, Error> {
        guard reachability.canConnect else {
            return .failure(InternetReachabilityError.internetUnreachable)
        }
        walletManager.loadWalletJS()
        walletManager.recoverFromMetadata(seedPhrase: passphrase)
        return .success(())
    }

    public func execute() -> Result<Void, Error> {
        guard reachability.canConnect else {
            return .failure(InternetReachabilityError.internetUnreachable)
        }
        walletManager.loadWalletJS()

        let email: String = contentStateRelay.value.email
        let password: String = contentStateRelay.value.password
        walletManager.recover(
            email: email,
            password: password,
            seedPhrase: passphrase
        )
        return .success(())
    }
}
