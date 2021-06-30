// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import ComposableArchitecture
import DIKit
import PlatformUIKit
import UIKit

/// Acts as the main controller for onboarding and logged in states
final class AppHostingController: UIViewController {
    let store: Store<CoreAppState, CoreAppAction>
    let viewStore: ViewStore<CoreAppState, CoreAppAction>
    private var cancellables: Set<AnyCancellable> = []

    @LazyInject var alertViewPresenter: AlertViewPresenterAPI

    private var onboardingController: OnboardingHostingController?
    private var loggedInController: LoggedInHostingController?
    private var loggedInDependencyBridge: LoggedInDependencyBridgeAPI

    init(store: Store<CoreAppState, CoreAppAction>,
         loggedInDependencyBridge: LoggedInDependencyBridgeAPI = resolve()) {
        self.store = store
        self.viewStore = ViewStore(store)
        self.loggedInDependencyBridge = loggedInDependencyBridge
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = #colorLiteral(red: 0.0431372549, green: 0.1019607843, blue: 0.2784313725, alpha: 1)

        viewStore.publisher
            .alertContent
            .compactMap { $0 }
            .removeDuplicates()
            .sink { [weak self] content in
                guard let self = self else { return }
                self.showAlert(with: content)
            }
            .store(in: &cancellables)

        store
            .scope(state: \.onboarding, action: CoreAppAction.onboarding)
            .ifLet(then: { [weak self] onboardingStore in
                guard let self = self else { return }
                let onboardingController = OnboardingHostingController(store: onboardingStore)
                if let loggedInController = self.loggedInController {
                    self.transition(from: loggedInController,
                                    to: onboardingController,
                                    animate: true)
                } else {
                    self.add(child: onboardingController)
                }
                self.onboardingController = onboardingController
                self.loggedInDependencyBridge.unregister()
                self.loggedInController?.clear()
                self.loggedInController = nil
            })
            .store(in: &cancellables)

        store
            .scope(state: \.loggedIn, action: CoreAppAction.loggedIn)
            .ifLet(then: { [weak self] loggedInScope in
                guard let self = self else { return }
                let loggedInController = LoggedInHostingController(store: loggedInScope)
                // this is important, register the controller as a bridge
                // for many places throughout the app
                self.loggedInDependencyBridge.register(bridge: loggedInController)
                if let onboardingController = self.onboardingController {
                    self.transition(from: onboardingController,
                                    to: loggedInController,
                                    animate: true)
                } else {
                    self.add(child: loggedInController)
                }
                self.loggedInController = loggedInController
                self.onboardingController = nil
            })
            .store(in: &cancellables)
    }

    private func showAlert(with content: AlertViewContent) {
        alertViewPresenter.notify(content: content, in: self)
    }
}
