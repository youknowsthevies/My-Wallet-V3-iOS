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

    init(store global: Store<LoggedIn.State, LoggedIn.Action>) {

        let environment = LoggedInRootEnvironment()
        let store = Store(
            initialState: LoggedInRootState(),
            reducer: loggedInRootReducer,
            environment: environment
        )

        viewStore = ViewStore(store)

        super.init(rootView: LoggedInRootView(store: store))

        subscribe(to: ViewStore(global))
        subscribe(to: viewStore)

        environment.publisher
            .sink(to: My.handle(state:action:), on: self)
            .store(in: &bag)
    }

    @objc dynamic required init?(coder aDecoder: NSCoder) {
        unimplemented()
    }

    var tabControllerManager: TabControllerManager? { // ← Remove requirement from LoggedInBridge
        get { #function.peek("‼️ not implemented"); return nil }
        set { #function.peek("‼️ not implemented. newValue = \(String(describing: newValue))") }
    }

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
                output.peek("‼️ not implemented")
            }
            .store(in: &bag)

        viewStore.publisher
            .reloadAfterSymbolChanged
            .filter { $0 }
            .sink { output in
                output.peek("‼️ not implemented")
            }
            .store(in: &bag)

        viewStore.publisher
            .displayWalletAlertContent
            .compactMap { $0 }
            .removeDuplicates()
            .sink { output in
                "\(output)".peek("‼️ not implemented")
            }
            .store(in: &bag)

        viewStore.publisher
            .displaySendCryptoScreen
            .filter(\.self)
            .sink { output in
                output.peek("‼️ not implemented")
            }
            .store(in: &bag)

        viewStore.publisher
            .displayOnboardingFlow
            .filter(\.self)
            .sink { output in
                output.peek("‼️ not implemented")
            }
            .store(in: &bag)

        viewStore.publisher
            .displayLegacyBuyFlow
            .filter(\.self)
            .sink { output in
                output.peek("‼️ not implemented")
            }
            .store(in: &bag)
    }
}

extension LoggedInRootViewController {

    func subscribe(to viewStore: ViewStore<LoggedInRootState, LoggedInRootAction>) {
        #function.peek("‼️ not implemented")
    }

    func handle(state: LoggedInRootState, action: LoggedInRootAction) {
        switch action {
        case .frequentAction(let frequentAction):
            switch frequentAction {
            case .swap:
                handleSwapCrypto(account: nil)
            case .send:
                "\(action)".peek("‼️ not implemented")
            case .receive:
                "\(action)".peek("‼️ not implemented")
            case .rewards:
                "\(action)".peek("‼️ not implemented")
            case .deposit:
                "\(action)".peek("‼️ not implemented")
            case .withdraw:
                "\(action)".peek("‼️ not implemented")
            case .buy:
                handleBuyCrypto(account: nil)
            case .sell:
                handleSellCrypto(account: nil)
            default:
                assertionFailure("Unhandled action \(action)")
            }
        default:
            break
        }
    }
}
