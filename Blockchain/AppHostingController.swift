// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import ComposableArchitecture
import UIKit

/// Acts as the main controller for onboarding and logged in states
final class AppHostingController: UIViewController {
    let store: Store<CoreAppState, CoreAppAction>
    private var cancellables: Set<AnyCancellable> = []

    private var onboardingController: OnboardingHostingController?
    private var loggedInController: LoggedInHostingController?

    init(store: Store<CoreAppState, CoreAppAction>) {
        self.store = store
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = #colorLiteral(red: 0.0431372549, green: 0.1019607843, blue: 0.2784313725, alpha: 1)

        self.store
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
                self.loggedInController = nil
            })
            .store(in: &cancellables)

        self.store
            .scope(state: \.loggedIn, action: CoreAppAction.loggedIn)
            .ifLet(then: { [weak self] loggedInScope in
                guard let self = self else { return }
                let loggedInController = LoggedInHostingController(store: loggedInScope)
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
}
