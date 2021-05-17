// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformKit
import RxRelay
import RxSwift

public protocol NonCustodialActionRouterAPI: class {
    func next(to state: NonCustodialActionState)
    func start(with currency: CryptoCurrency)
}

public final class NonCustodialActionRouter: NonCustodialActionRouterAPI {

    // MARK: - `Router` Properties

    private var stateService: NonCustodialActionStateService!
    private let balanceProviding: BalanceProviding
    private let navigationRouter: NavigationRouterAPI
    private let routing: CurrencyRouting & TabSwapping
    private let disposeBag = DisposeBag()
    private var currency: CryptoCurrency!

    public init(navigationRouter: NavigationRouterAPI = NavigationRouter(),
                balanceProvider: BalanceProviding,
                routing: CurrencyRouting & TabSwapping) {
        self.balanceProviding = balanceProvider
        self.navigationRouter = navigationRouter
        self.routing = routing
    }

    public func start(with currency: CryptoCurrency) {
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
        let interactor = WalletActionScreenInteractor(
            accountType: .nonCustodial,
            currency: .crypto(currency),
            service: balanceProviding[currency.currency]
        )
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
            self.routing.switchToActivity(currency: self.currency)
        }
    }

    private func showReceiveScreen() {
        dismissTopMost { [weak self] in
            guard let self = self else { return }
            self.navigationRouter.topMostViewControllerProvider.topMostViewController?.dismiss(animated: true, completion: nil)
            self.routing.toReceive(self.currency)
        }
    }

    private func showSendScreen() {
        dismissTopMost { [weak self] in
            guard let self = self else { return }
            self.navigationRouter.topMostViewControllerProvider.topMostViewController?.dismiss(animated: true, completion: nil)
            self.routing.toSend(self.currency)
        }
    }

    private func dismissTopMost(completion: (() -> Void)? = nil) {
        navigationRouter.topMostViewControllerProvider.topMostViewController?.dismiss(animated: true, completion: completion)
    }

    private lazy var sheetPresenter: BottomSheetPresenting = {
        BottomSheetPresenting(ignoresBackroundTouches: false)
    }()
}
