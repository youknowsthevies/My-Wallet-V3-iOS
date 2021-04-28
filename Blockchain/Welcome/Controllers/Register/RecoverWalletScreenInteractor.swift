//
//  RecoverWalletScreenInteractor.swift
//  Blockchain
//
//  Created by Daniel Huri on 15/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import AnalyticsKit
import DIKit
import PlatformKit
import RxRelay
import RxSwift
import ToolKit

final class RecoverWalletScreenInteractor {
    
    // MARK: - Exposed Properties
    
    let contentStateRelay = BehaviorRelay(value: WalletRegistrationContent())
    var content: Observable<WalletRegistrationContent> {
        contentStateRelay.asObservable()
    }

    /// Reflects errors received from the JS layer
    var error: Observable<String> {
        errorRelay.asObservable()
    }
    
    // MARK: - Injected
    
    private let reachability: InternetReachabilityAPI
    private let analyticsRecorder: AnalyticsEventRecording
    private let wallet: Wallet
    private let walletManager: WalletManager
    
    /// A passphrase for recovery
    private let passphrase: String
    
    // MARK: - Accessors
    
    private let errorRelay = PublishRelay<String>()
    
    // MARK: - Setup
    
    init(authenticationCoordinator: AuthenticationCoordinator = .shared,
         passphrase: String,
         analyticsRecorder: AnalyticsEventRecording = resolve(),
         reachability: InternetReachabilityAPI = InternetReachability(),
         walletManager: WalletManager = .shared,
         wallet: Wallet = WalletManager.shared.wallet) {
        self.passphrase = passphrase
        self.analyticsRecorder = analyticsRecorder
        self.reachability = reachability
        self.walletManager = walletManager
        self.wallet = wallet
        authenticationCoordinator.temporaryAuthHandler = authenticationCoordinator.authenticationHandler
    }
}

// MARK: - RegisterWalletScreenInteracting

extension RecoverWalletScreenInteractor: RegisterWalletScreenInteracting {
    func prepare() throws {
        guard reachability.canConnect else {
            throw InternetReachability.ErrorType.internetUnreachable
        }
        wallet.loadJS()
        wallet.delegate = WalletManager.shared
        wallet.recoverFromMetadata(withMnemonicPassphrase: passphrase)
    }

    func execute() throws {
        guard reachability.canConnect else {
            throw InternetReachability.ErrorType.internetUnreachable
        }
        wallet.loadJS()
        wallet.delegate = WalletManager.shared
        let email: String = contentStateRelay.value.email
        let password: String = contentStateRelay.value.password
        wallet.recover(
            withEmail: email,
            password: password,
            mnemonicPassphrase: passphrase
        )
    }
}
