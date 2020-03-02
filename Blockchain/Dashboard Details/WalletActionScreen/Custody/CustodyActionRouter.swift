//
//  CustodySendRouter.swift
//  Blockchain
//
//  Created by AlexM on 2/5/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import PlatformUIKit
import RxSwift
import RxRelay

protocol CustodyActionRouterAPI: class {
    func next(to state: CustodyActionStateService.State)
    func previous()
    func start(with currency: CryptoCurrency)
    var completionRelay: PublishRelay<Void> { get }
}

final class CustodyActionRouter: CustodyActionRouterAPI, Router {
    
    // MARK: - `Router` Properties
    
    weak var topMostViewControllerProvider: TopMostViewControllerProviding!
    weak var navigationControllerAPI: NavigationControllerAPI?
    
    let completionRelay = PublishRelay<Void>()
    
    private var stateService: CustodyActionStateServiceAPI!
    private let simpleBuyAPI: SimpleBuyServiceProviderAPI
    private let appSettings: BlockchainSettings.App
    private let backupRouterAPI: BackupRouterAPI
    private let custodyWithdrawalRouter: CustodyWithdrawalRouterAPI
    private let dataProviding: DataProviding
    private var currency: CryptoCurrency!
    private let disposeBag = DisposeBag()
    
    init(topMostViewControllerProvider: TopMostViewControllerProviding = UIApplication.shared,
         appSettings: BlockchainSettings.App = BlockchainSettings.App.shared,
         dataProviding: DataProviding = DataProvider.default,
         simpleBuyAPI: SimpleBuyServiceProviderAPI = SimpleBuyServiceProvider.default,
         custodyWithdrawalRouter: CustodyWithdrawalRouterAPI = CustodyWithdrawalRouter(),
         backupRouterAPI: BackupRouterAPI) {
        self.custodyWithdrawalRouter = custodyWithdrawalRouter
        self.appSettings = appSettings
        self.dataProviding = dataProviding
        self.backupRouterAPI = backupRouterAPI
        self.simpleBuyAPI = simpleBuyAPI
        self.topMostViewControllerProvider = topMostViewControllerProvider
        
        self.backupRouterAPI
            .completionRelay
            .bind(weak: self, onNext: { (self, _) in
                self.stateService.nextRelay.accept(())
            })
            .disposed(by: disposeBag)
        
        self.custodyWithdrawalRouter.completionRelay
            .bind(to: completionRelay)
            .disposed(by: disposeBag)
    }
    
    func start(with currency: CryptoCurrency) {
        // TODO: Would much prefer a different form of injection
        // but we build our `Routers` in the AppCoordinator
        self.currency = currency
        self.stateService = CustodyActionStateService()
        
        stateService.action
            .bind(weak: self) { (self, action) in
                switch action {
                case .previous:
                    self.previous()
                case .next(let state):
                    self.next(to: state)
                case .dismiss:
                    self.navigationControllerAPI?.dismiss(animated: true, completion: nil)
                }
            }
            .disposed(by: disposeBag)
        stateService.nextRelay.accept(())
    }
    
    func next(to state: CustodyActionStateService.State) {
        switch state {
        case .start:
            break
        case .introduction:
            /// The `topMost` screen is the `CustodyActionScreen`
            dismissTopMost { [weak self] in
                guard let self = self else { return }
                self.showIntroductionScreen()
            }
        case .backup,
             .backupAfterIntroduction:
            /// The `topMost` screen is the `CustodyActionScreen`
            dismissTopMost { [weak self] in
                guard let self = self else { return }
                self.backupRouterAPI.start()
            }
        case .send:
            showSendCustody()
        case .withdrawalAfterBackup:
            /// `Backup` has already been dismissed as `Backup`
            /// has ended. `CustodyActionScreen` has been dismissed
            /// prior to `Backup`. There is no `topMost` screen that
            /// needs to be dismissed.
            custodyWithdrawalRouter.start(with: currency)
        case .withdrawal:
            /// The `topMost` screen is the `CustodyActionScreen`
            dismissTopMost { [weak self] in
                guard let self = self else { return }
                self.custodyWithdrawalRouter.start(with: self.currency)
            }
        case .end:
            dismissTopMost()
        }
    }
    
    private func showSendCustody() {
        let interactor = WalletActionScreenInteractor(
            balanceType: .custodial, currency: currency,
            service: dataProviding.balance[currency]
        )
        let presenter = CustodialActionScreenPresenter(using: interactor, stateService: stateService)
        let controller = WalletActionScreenViewController(using: presenter)
        controller.transitioningDelegate = sheetPresenter
        controller.modalPresentationStyle = .custom
        topMostViewControllerProvider.topMostViewController?.present(controller, animated: true, completion: nil)
    }
    
    private func showIntroductionScreen() {
        let presenter = CustodyInformationScreenPresenter(stateService: stateService)
        let controller = CustodyInformationViewController(presenter: presenter)
        if #available(iOS 13.0, *) {
            controller.isModalInPresentation = true
        }
        present(viewController: controller, using: .modalOverTopMost)
    }
    
    func previous() {
        dismiss()
    }
    
    private func dismissTopMost(completion: (() -> Void)? = nil) {
        topMostViewControllerProvider.topMostViewController?.dismiss(animated: true, completion: completion)
    }
    
    private lazy var sheetPresenter: BottomSheetPresenting = {
        return BottomSheetPresenting()
    }()
}

