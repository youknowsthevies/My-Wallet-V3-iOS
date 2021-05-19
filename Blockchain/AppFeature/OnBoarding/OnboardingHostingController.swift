// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import ComposableArchitecture
import UIKit

/// Acts as a container for Pin screen and Login screen
final class OnboardingHostingController: UIViewController {
    let store: Store<Onboarding.State, Onboarding.Action>

    private var cancellables: Set<AnyCancellable> = []

    private var pinHostingController: PinHostingController?

    init(store: Store<Onboarding.State, Onboarding.Action>) {
        self.store = store
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
                let pinHostingController = PinHostingController(store: pinStore)
                self?.add(child: pinHostingController)
                self?.pinHostingController = pinHostingController
            })
            .store(in: &cancellables)
    }
}
