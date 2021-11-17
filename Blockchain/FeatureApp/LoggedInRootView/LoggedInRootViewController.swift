//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.

import Combine
import ComposableArchitecture
import FeatureAppUI
import FeatureAuthenticationDomain
import SwiftUI
import ToolKit

final class LoggedInRootViewController: UIHostingController<LoggedInRootView> {

    let store: Store<LoggedIn.State, LoggedIn.Action>

    init(store: Store<LoggedIn.State, LoggedIn.Action>) {
        self.store = store
        super.init(rootView: LoggedInRootView())
    }

    @objc dynamic required init?(coder aDecoder: NSCoder) {
        unimplemented()
    }

    var tabControllerManager: TabControllerManager?

    var bag: Set<AnyCancellable> = []

    func clear() {
        tabControllerManager = nil
        bag.removeAll()
    }
}

struct LoggedInRootView: View {

    var body: some View {
        EmptyView()
    }
}
