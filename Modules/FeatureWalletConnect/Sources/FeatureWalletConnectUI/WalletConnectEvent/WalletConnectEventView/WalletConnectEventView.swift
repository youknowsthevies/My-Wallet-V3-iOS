// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import Combine
import ComposableArchitecture
import FeatureWalletConnectDomain
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
let meta = Session.ClientMeta(
    name: "Uniswap Interface",
    description: "Swap or provide liquidity on the Uniswap Protocol",
    icons: [URL(string: "https://app.uniswap.org/./images/512x512_App_Icon.png")!],
    url: URL(string: "https://app.uniswap.org")!
)

let dAppInfo = Session.DAppInfo(peerId: "", peerMeta: meta)
let walletInfo = Session.WalletInfo(
    approved: true,
    accounts: [],
    chainId: 1,
    peerId: "",
    peerMeta: meta
)

let session = Session(
    url: WCURL(topic: "", bridgeURL: URL(string: "blockchain.com")!, key: ""),
    dAppInfo: dAppInfo,
    walletInfo: walletInfo
)

class MockWalletConnectService: WalletConnectServiceAPI {
    var sessionEvents: AnyPublisher<WalletConnectSessionEvent, Never> {
        Future<WalletConnectSessionEvent, Never> { _ in }
            .eraseToAnyPublisher()
    }

    var userEvents: AnyPublisher<WalletConnectUserEvent, Never> {
        Future<WalletConnectUserEvent, Never> { _ in }
            .eraseToAnyPublisher()
    }

    func connect(_ url: String) {}
    func disconnect(_ session: Session) {}
    func acceptConnection(_ completion: @escaping (Session.WalletInfo) -> Void) {}
    func denyConnection(_ completion: @escaping (Session.WalletInfo) -> Void) {}
}

class MockWalletConnectRouter: WalletConnectRouterAPI {
    func showConnectedDApps() {}
    func showSessionDetails(session: WalletConnectSession) -> AnyPublisher<Void, Never> {
        .just(())
    }

    func openWebsite(for client: Session.ClientMeta) {}
}

class MockAnalyticsRecorder: AnalyticsEventRecorderAPI {
    func record(event: AnalyticsEvent) {}
}

struct ConnectView_Previews: PreviewProvider {
    static var previews: some View {

        let environment = WalletConnectEventEnvironment(
            mainQueue: .main,
            service: MockWalletConnectService(),
            router: MockWalletConnectRouter(),
            analyticsEventRecorder: MockAnalyticsRecorder(),
            onComplete: { _ in }
        )
        let store = Store(
            initialState: WalletConnectEventState(session: session, state: .idle),
            reducer: walletConnectEventReducer,
            environment: environment
        )
        return WalletConnectEventView(store: store)
    }
}
#endif
