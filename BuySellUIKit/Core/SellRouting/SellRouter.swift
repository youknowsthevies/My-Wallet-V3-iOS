//
//  SellRouter.swift
//  BuySellUIKit
//
//  Created by Daniel on 07/08/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import BuySellKit
import Localization
import PlatformKit
import PlatformUIKit
import RxSwift
import ToolKit
import DIKit

public final class SellRouter: PlatformUIKit.Router<SellRouterInteractor> {
    
    // MARK: - Injected
    
    private let routingType: RoutingType
    private let navigationRouter: NavigationRouterAPI
    private let builder: SellBuilderAPI
    
    private let disposeBag = DisposeBag()
    
    public init(routingType: RoutingType = .modal,
                navigationRouter: NavigationRouterAPI = NavigationRouter(),
                builder: SellBuilderAPI) {
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
        case .inactive:
            fatalError("\(state.debugDescription) state must not be reached")
        case .completed:
            break
        case .enterAmount(let data):
            self.navigateToEnterAmountScreen(with: data)
        }
    }
    
    private func previous(from state: SellRouterInteractor.State) {
        switch state {
        case .inactive:
            fatalError("\(state.debugDescription) state must not be reached")
        case .enterAmount:
            navigationRouter.dismiss()
        case .completed:
            navigationRouter.dismiss()
        }
    }
    
    // MARK: - Navigation Accessors
    
    private func navigateToEnterAmountScreen(with data: SellCryptoInteractionData) {
        let viewController = builder.sellCryptoViewController(data: data)
        navigationRouter.present(viewController: viewController)
    }
}
