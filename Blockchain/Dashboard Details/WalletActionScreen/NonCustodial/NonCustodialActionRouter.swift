//
//  NonCustodialActionRouter.swift
//  Blockchain
//
//  Created by AlexM on 2/27/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import PlatformUIKit
import RxSwift
import RxRelay

protocol NonCustodialActionRouterAPI: class {
    func next(to state: NonCustodialActionState)
    func start(with currency: CryptoCurrency)
}

final class NonCustodialActionRouter: NonCustodialActionRouterAPI, Router {
    
    // MARK: - `Router` Properties
    
    weak var topMostViewControllerProvider: TopMostViewControllerProviding!
    weak var navigationControllerAPI: NavigationControllerAPI?
    
    private var stateService: NonCustodialActionStateService!
    private let dataProviding: DataProviding
    private let tabSwapping: TabSwapping
    private let disposeBag = DisposeBag()
    private var currency: CryptoCurrency!
    
    init(topMostViewControllerProvider: TopMostViewControllerProviding = UIApplication.shared,
         dataProviding: DataProviding = DataProvider.default,
         tabSwapping: TabSwapping) {
        self.dataProviding = dataProviding
        self.topMostViewControllerProvider = topMostViewControllerProvider
        self.tabSwapping = tabSwapping
    }
    
    func start(with currency: CryptoCurrency) {
        // TODO: Would much prefer a different form of injection
        // but we build our `Routers` in the AppCoordinator
        self.currency = currency
        self.stateService = NonCustodialActionStateService()
        
        stateService.action
            .bindAndCatch(weak: self) { (self, action) in
                switch action {
                case .previous, .dismiss:
                    break
                case .next(let state):
                    self.next(to: state)
                }
            }
            .disposed(by: disposeBag)
        stateService.nextRelay.accept(())
    }
    
    func next(to state: NonCustodialActionState) {
        /// Dismiss the `WalletScreenActionViewController`
        switch state {
        case .actions:
            showNonCustodialActionScreen()
        case .swap:
            showSwapScreen()
        case .activity:
            showActivityScreen()
        }
    }
    
    private func showNonCustodialActionScreen() {
        let interactor = WalletActionScreenInteractor(
            balanceType: .nonCustodial,
            currency: currency,
            service: dataProviding.balance[currency]
        )
        let presenter = NonCustodialActionScreenPresenter(using: interactor, stateService: stateService)
        let controller = WalletActionScreenViewController(using: presenter)
        controller.transitioningDelegate = sheetPresenter
        controller.modalPresentationStyle = .custom
        topMostViewControllerProvider.topMostViewController?.present(controller, animated: true, completion: nil)
    }
    
    private func showSwapScreen() {
        dismissTopMost { [weak self] in
            guard let self = self else { return }
            self.topMostViewControllerProvider.topMostViewController?.dismiss(animated: true, completion: nil)
            self.tabSwapping.switchTabToSwap()
        }
    }
    
    private func showActivityScreen() {
        dismissTopMost { [weak self] in
            guard let self = self else { return }
            self.topMostViewControllerProvider.topMostViewController?.dismiss(animated: true, completion: nil)
            self.tabSwapping.switchToActivity(currency: self.currency)
        }
    }
    
    private func dismissTopMost(completion: (() -> Void)? = nil) {
        topMostViewControllerProvider.topMostViewController?.dismiss(animated: true, completion: completion)
    }
    
    private lazy var sheetPresenter: BottomSheetPresenting = {
        return BottomSheetPresenting(ignoresBackroundTouches: false)
    }()
}

