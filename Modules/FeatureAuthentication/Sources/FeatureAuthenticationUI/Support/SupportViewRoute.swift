// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
import ComposableNavigation
import SwiftUI
import UIComponentsKit

enum SupportViewRoute: NavigationRoute, CaseIterable {

    case contactUs
    case viewFAQs

    @ViewBuilder
    func destination(in store: Store<SupportViewState, SupportViewAction>) -> some View {
        switch self {
        case .contactUs:
            SafariView(
                destination: "https://support.blockchain.com/hc/en-us/requests/new"
            )
        case .viewFAQs:
            SafariView(
                destination: "https://support.blockchain.com/hc/en-us/categories/4416659837460-Wallet"
            )
        }
    }
}
