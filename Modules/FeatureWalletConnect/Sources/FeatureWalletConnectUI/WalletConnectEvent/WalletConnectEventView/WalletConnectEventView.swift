// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
import SwiftUI
import WalletConnectSwift

struct WalletConnectEventView: View {
    private let store: Store<WalletConnectEventState, WalletConnectEventAction>

    init(store: Store<WalletConnectEventState, WalletConnectEventAction>) {
        self.store = store
    }

    var body: some View {
        ZStack {
            BottomSheet(store: store)
        }
        .backgroundTexture(.lightContentBackground.opacity(0.64))
    }
}

// MARK: SwiftUI Preview

#if DEBUG
struct ConnectView_Previews: PreviewProvider {
    static var previews: some View {
        let meta = Session.ClientMeta(
            name: "Uniswap Interface",
            description: "Swap or provide liquidity on the Uniswap Protocol",
            icons: [URL(string: "https://app.uniswap.org/./images/512x512_App_Icon.png")!],
            url: URL(string: "https://app.uniswap.org")!
        )
        let environment = WalletConnectEventEnvironment(
            mainQueue: .main,
            onComplete: { _ in }
        )
        let store = Store(
            initialState: WalletConnectEventState(meta: meta, state: .idle),
            reducer: walletConnectEventReducer,
            environment: environment
        )
        return WalletConnectEventView(store: store)
    }
}
#endif
