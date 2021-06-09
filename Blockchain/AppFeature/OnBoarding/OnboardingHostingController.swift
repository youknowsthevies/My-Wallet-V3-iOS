// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import ComposableArchitecture
import PlatformUIKit
import UIKit

/// Acts as a container for Pin screen and Login screen
final class OnboardingHostingController: UIViewController {
    let store: Store<Onboarding.State, Onboarding.Action>
    let viewStore: ViewStore<Onboarding.State, Onboarding.Action>
    private var cancellables: Set<AnyCancellable> = []

    private var currentController: UIViewController?

    init(store: Store<Onboarding.State, Onboarding.Action>) {
        self.store = store
        self.viewStore = ViewStore(store)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        store
            .scope(state: \.pinState, action: Onboarding.Action.pin)
            .ifLet(then: { [weak self] pinStore in
                guard let self = self else { return }
                let pinHostingController = PinHostingController(store: pinStore)
                self.transitionFromCurrentController(to: pinHostingController)
                self.currentController = pinHostingController
            })
            .store(in: &cancellables)

        store
            .scope(state: \.walletUpgradeState, action: Onboarding.Action.walletUpgrade)
            .ifLet(then: { [weak self] _ in
                guard let self = self else { return }
                let walletUpgradeController = self.setupWalletUpgrade {
                    self.viewStore.send(.walletUpgrade(.completed))
                }
                self.transitionFromCurrentController(to: walletUpgradeController)
                self.currentController = walletUpgradeController
            })
            .store(in: &cancellables)
    }

    // MARK: Private

    /// Transition from the current controller, if any to the specified controller.
    private func transitionFromCurrentController(to controller: UIViewController) {
        if let currentController = self.currentController {
            self.transition(from: currentController,
                            to: controller,
                            animate: true)
        } else {
            self.add(child: controller)
        }
    }

    // Provides the view controller that displays the wallet upgrade
    private func setupWalletUpgrade(completion: @escaping () -> Void) -> WalletUpgradeViewController {
        let interactor = WalletUpgradeInteractor(completion: completion)
        let presenter = WalletUpgradePresenter(interactor: interactor)
        let viewController = WalletUpgradeViewController(presenter: presenter)
        return viewController
    }
}
