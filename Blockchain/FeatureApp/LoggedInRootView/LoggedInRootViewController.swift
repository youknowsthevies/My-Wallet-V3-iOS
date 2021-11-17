//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.

import Combine
import ComposableArchitecture
import FeatureAppUI
import FeatureAuthenticationDomain
import SwiftUI
import ToolKit

final class LoggedInRootViewController: UIHostingController<LoggedInRootView> {

    let viewStore: ViewStore<LoggedInRootState, LoggedInRootAction>
    var bag: Set<AnyCancellable> = []

    enum Action {
        case frequentAction(FrequentAction)
    }

    let publisher: AnyPublisher<Action, Never>

    init(store global: Store<LoggedIn.State, LoggedIn.Action>) {

        let subject = PassthroughSubject<Action, Never>()
        let store = Store(
            initialState: LoggedInRootState(),
            reducer: loggedInRootReducer,
            environment: LoggedInRootEnvironment(
                frequentAction: { frequentAction in
                    subject.send(.frequentAction(frequentAction))
                }
            )
        )

        viewStore = ViewStore(store)
        publisher = subject.eraseToAnyPublisher()

        super.init(rootView: LoggedInRootView(store: store))

        subscribe(to: ViewStore(global))
        subscribe(to: viewStore)

        publisher
            .sink(to: LoggedInRootViewController.handle(action:), on: self)
            .store(in: &bag)
    }

    @objc dynamic required init?(coder aDecoder: NSCoder) {
        unimplemented()
    }

    var tabControllerManager: TabControllerManager? // ← Remove requirement from LoggedInBridge

    func clear() {
        tabControllerManager = nil
        bag.removeAll()
    }
}

extension LoggedInRootViewController {

    func subscribe(to viewStore: ViewStore<LoggedIn.State, LoggedIn.Action>) {

        viewStore.publisher
            .reloadAfterMultiAddressResponse
            .filter { $0 }
            .sink { output in
                output.peek("‼️ Not Implemented")
            }
            .store(in: &bag)

        viewStore.publisher
            .reloadAfterSymbolChanged
            .filter { $0 }
            .sink { output in
                output.peek("‼️ Not Implemented")
            }
            .store(in: &bag)

        viewStore.publisher
            .displayWalletAlertContent
            .compactMap { $0 }
            .removeDuplicates()
            .sink { output in
                "\(output)".peek("‼️ Not Implemented")
            }
            .store(in: &bag)

        viewStore.publisher
            .displaySendCryptoScreen
            .filter(\.self)
            .sink { output in
                output.peek("‼️ Not Implemented")
            }
            .store(in: &bag)

        viewStore.publisher
            .displayOnboardingFlow
            .filter(\.self)
            .sink { output in
                output.peek("‼️ Not Implemented")
            }
            .store(in: &bag)

        viewStore.publisher
            .displayLegacyBuyFlow
            .filter(\.self)
            .sink { output in
                output.peek("‼️ Not Implemented")
            }
            .store(in: &bag)
    }
}

extension LoggedInRootViewController {

    func subscribe(to viewStore: ViewStore<LoggedInRootState, LoggedInRootAction>) {
        #function.peek("‼️ Not Implemented")
    }

    func handle(action: Action) {
        #function.peek("‼️ \(action) Not Implemented")
    }
}
