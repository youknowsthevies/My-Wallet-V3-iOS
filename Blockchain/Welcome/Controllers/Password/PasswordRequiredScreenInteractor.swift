//
//  PasswordRequiredScreenInteractor.swift
//  Blockchain
//
//  Created by Daniel Huri on 16/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay
import PlatformKit

final class PasswordRequiredScreenInteractor {
    
    // MARK: - Properties
    
    /// Streams potential parsing errors
    var error: Observable<Error> {
        return errorRelay.asObservable()
    }
    
    /// Relay that accepts and streams the payload content
    let passwordRelay = BehaviorRelay<String>(value: "")

    private let walletPayloadService: WalletPayloadServiceAPI
    private let walletFetcher: PairingWalletFetching
    private let appSettings: BlockchainSettings.App
    private let walletManager: WalletManager
    
    /// TODO: Consider the various of error types from the service layer,
    /// translate them into a interaction layer errors
    private let errorRelay = PublishRelay<Error>()
    
    private let disposeBag = DisposeBag()
    
    // MARK: - Setup
    
    init(walletPayloadService: WalletPayloadServiceAPI = WalletPayloadService(
        repository: WalletManager.shared.repository
        ),
         walletManager: WalletManager = .shared,
         walletFetcher: PairingWalletFetching = AuthenticationCoordinator.shared,
         appSettings: BlockchainSettings.App = .shared) {
        self.walletPayloadService = walletPayloadService
        self.walletManager = walletManager
        self.walletFetcher = walletFetcher
        self.appSettings = appSettings
    }
    
    /// Authenticates the wallet
    func authenticate() {
        walletPayloadService.requestUsingSharedKey()
            .subscribe(
                onCompleted: { [weak self] in
                    guard let self = self else { return }
                    self.walletFetcher.authenticate(using: self.passwordRelay.value)
                },
                onError: errorRelay.accept
            )
            .disposed(by: disposeBag)
    }
    
    /// Forgets the wallet
    func forget() {
        walletManager.forgetWallet()
        appSettings.clear()
    }
}
