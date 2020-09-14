//
//  SellRouter.swift
//  BuySellUIKit
//
//  Created by Daniel on 07/08/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import BuySellKit
import DIKit
import Localization
import PlatformKit
import PlatformUIKit
import RxSwift
import ToolKit

public final class SellRouter: PlatformUIKit.Router<SellRouterInteractor> {
    
    // MARK: - Injected
    
    private let routingType: RoutingType
    private let navigationRouter: NavigationRouterAPI
    private let builder: SellBuilderAPI
    private let kycRouter: KYCRouterAPI
    
    /// A kyc subscription dispose bag
    private var kycDisposeBag = DisposeBag()
    private let disposeBag = DisposeBag()
    
    public init(routingType: RoutingType = .modal,
                navigationRouter: NavigationRouterAPI = NavigationRouter(),
                kycRouter: KYCRouterAPI,
                builder: SellBuilderAPI) {
        self.kycRouter = kycRouter
        self.navigationRouter = navigationRouter
        self.routingType = routingType
        self.builder = builder
        super.init(interactor: builder.routerInteractor)
    }
    
    // MARK: - Lifecycle
    
    public override func willLoad() {
        super.willLoad()
        
        // Embed the entire flow in another navigation controller
        // instead of generating one of its own
        if case .embed(inside: let navigationController) = routingType {
            navigationRouter.navigationControllerAPI = navigationController
        }
        
        // Action is a steam of events derived from a pblish relay
        interactor.action
            .emit(weak: self) { (self, action) in
                switch action {
                case .previous(from: let state):
                    self.previous(from: state)
                case .next(to: let state):
                    self.next(to: state)
                case .dismiss:
                    self.navigationRouter.navigationControllerAPI?.dismiss(animated: true, completion: nil)
                }
            }
            .disposed(by: disposeBag)
        
        /// TODO: Remove once `AppCoordinator` moves into RIBs because Should be automatically
        /// called by `Router` once `self` is attached as a child router.
        interactor.activate()
    }
    
    public override func didLoad() {
        super.didLoad()
    }
    
    private func next(to state: SellRouterInteractor.State) {
        switch state {
        case .accountSelector:
            navigateToAccountSelectorScreen()
        case .fiatAccountSelector:
            navigationRouter.dismiss { [weak self] in
                guard let self = self else { return }
                self.navigateToFiatAccountSelectorScreen()
            }
        case .checkout(let data):
            navigationToCheckoutScreen(with: data)
        case .kyc:
            navigationRouter.dismiss { [weak self] in
                guard let self = self else { return }
                self.showKYC()
            }
        case .introduction:
            navigateToSellIntroductionScreen()
        case .cancel(let data):
            break
        case .pendingOrderCompleted(orderDetails: let orderDetails):
            navigateToPendingScreen(orderDetails: orderDetails)
        case .completed,
             .inactive:
            break
        case .enterAmount(let data):
            navigationRouter.dismiss { [weak self] in
                guard let self = self else { return }
                self.navigateToEnterAmountScreen(with: data)
            }
        }
    }
    
    private func previous(from state: SellRouterInteractor.State) {
        switch state {
        case .inactive:
            fatalError("\(state.debugDescription) state must not be reached")
        case .enterAmount,
             .checkout,
             .completed,
             .cancel,
             .accountSelector,
             .pendingOrderCompleted,
             .fiatAccountSelector,
             .introduction,
             .kyc:
            navigationRouter.dismiss()
        }
    }
    
    // MARK: - Navigation Accessors
    
    private func showKYC() {
        kycDisposeBag = DisposeBag()
        let stopped = kycRouter.kycStopped
            .take(1)
            .observeOn(MainScheduler.instance)
            .share()
        
        stopped
            .filter { $0 == .tier2 }
            .mapToVoid()
            .bindAndCatch(weak: self) { (self) in
                self.interactor.nextFromKYC()
            }
            .disposed(by: kycDisposeBag)
        
        stopped
            .filter { $0 != .tier2 }
            .mapToVoid()
            .bindAndCatch(to: interactor.previousRelay)
            .disposed(by: kycDisposeBag)
        
        kycRouter.start(tier: .tier2)
    }
    
    private func navigateToSellIntroductionScreen() {
        let viewController = builder.sellIdentityIntroductionViewController()
        navigationRouter.present(viewController: viewController)
    }
    
    private func navigateToPendingScreen(orderDetails: OrderDetails) {
        let viewController = builder.pendingScreenViewController(for: orderDetails)
        navigationRouter.present(viewController: viewController)
    }
    
    private func navigateToTransferCancellation(with data: CheckoutData) {
        let viewController = builder.transferCancellationViewController(data: data)
        navigationRouter.present(viewController: viewController)
    }
    
    private func navigateToFiatAccountSelectorScreen() {
        let viewController = builder.fiatAccountSelectionViewController()
        navigationRouter.present(viewController: viewController, using: .modalOverTopMost)
    }
    
    private func navigateToAccountSelectorScreen() {
        let viewController = builder.accountSelectionViewController()
        navigationRouter.present(viewController: viewController)
    }
    
    private func navigateToEnterAmountScreen(with data: SellCryptoInteractionData) {
        let viewController = builder.sellCryptoViewController(data: data)
        navigationRouter.present(viewController: viewController, using: .modalOverTopMost)
    }
    
    private func navigationToCheckoutScreen(with data: CheckoutData) {
        let viewController = builder.checkoutScreenViewController(data: data)
        navigationRouter.present(viewController: viewController)
    }
}
