// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformKit
import RxRelay
import RxSwift

public protocol NonCustodialActionRouterAPI: class {
    func next(to state: NonCustodialActionState)
    func start(with account: BlockchainAccount)
}

public final class NonCustodialActionRouter: NonCustodialActionRouterAPI {

    // MARK: - `Router` Properties

    private var stateService: NonCustodialActionStateService!
    private let navigationRouter: NavigationRouterAPI
    private let routing: CurrencyRouting & TabSwapping
    private var disposeBag = DisposeBag()
    private var account: BlockchainAccount!

    public init(navigationRouter: NavigationRouterAPI = NavigationRouter(),
                routing: CurrencyRouting & TabSwapping) {
        self.navigationRouter = navigationRouter
        self.routing = routing
    }

    public func start(with account: BlockchainAccount) {
        // TODO: Would much prefer a different form of injection
        // but we build our `Routers` in the AppCoordinator
        self.disposeBag = DisposeBag()
        self.account = account
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

    public func next(to state: NonCustodialActionState) {
        /// Dismiss the `WalletScreenActionViewController`
        switch state {
        case .actions:
            showNonCustodialActionScreen()
        case .swap:
            showSwapScreen()
        case .activity:
            showActivityScreen()
        case .send:
            showSendScreen()
        case .receive:
            showReceiveScreen()
        }
    }

    private func showNonCustodialActionScreen() {
        let interactor = WalletActionScreenInteractor(account: account)
        let presenter = NonCustodialActionScreenPresenter(using: interactor, stateService: stateService)
        let controller = WalletActionScreenViewController(using: presenter)
        controller.transitioningDelegate = sheetPresenter
        controller.modalPresentationStyle = .custom
        navigationRouter.topMostViewControllerProvider.topMostViewController?.present(controller, animated: true, completion: nil)
    }

    private func showSwapScreen() {
        dismissTopMost { [weak self] in
            guard let self = self else { return }
            self.navigationRouter.topMostViewControllerProvider.topMostViewController?.dismiss(animated: true, completion: nil)
            self.routing.switchTabToSwap()
        }
    }

    private func showActivityScreen() {
        dismissTopMost { [weak self] in
            guard let self = self else { return }
            self.navigationRouter.topMostViewControllerProvider.topMostViewController?.dismiss(animated: true, completion: nil)
            self.routing.switchToActivity(for: self.account.currencyType)
        }
    }

    private func showReceiveScreen() {
        dismissTopMost { [weak self] in
            guard let self = self else { return }
            self.navigationRouter.topMostViewControllerProvider.topMostViewController?.dismiss(animated: true, completion: nil)
            self.routing.toReceive(self.account.currencyType)
        }
    }

    private func showSendScreen() {
        dismissTopMost { [weak self] in
            guard let self = self else { return }
            self.navigationRouter.topMostViewControllerProvider.topMostViewController?.dismiss(animated: true, completion: nil)
            self.routing.toSend(self.account.currencyType)
        }
    }

    private func dismissTopMost(completion: (() -> Void)? = nil) {
        navigationRouter.topMostViewControllerProvider.topMostViewController?.dismiss(animated: true, completion: completion)
    }

    private lazy var sheetPresenter: BottomSheetPresenting = {
        BottomSheetPresenting(ignoresBackroundTouches: false)
    }()
}
