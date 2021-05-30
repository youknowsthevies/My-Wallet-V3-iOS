// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import ComposableArchitecture
import UIKit

final class AppHostingController: UINavigationController {
    let store: Store<CoreAppState, CoreAppAction>
    private var cancellables: Set<AnyCancellable> = []

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
                self?.setViewControllers([OnboardingHostingController(store: onboardingStore)], animated: true)
            })
            .store(in: &cancellables)

        self.store
            .scope(state: \.loggedIn, action: CoreAppAction.loggedIn)
            .ifLet(then: { loggedInScore in
                //
            })
            .store(in: &cancellables)
    }
}
