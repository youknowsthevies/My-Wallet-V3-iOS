// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
import FeatureAuthenticationDomain
import SwiftUI
import UIComponentsKit

struct WebUpgradeAccountView: View {

    private enum MessageHandler {
        /// Message handler name for unified sign in communication
        static let ssi = "sessionHandler"
    }

    // TODO: change to dynamic config
    private static let url = "https://wallet-frontend-pre-release.dev.blockchain.info/#/login?product=wallet&platform=ios"

    private let callback: (String) -> Void
    @Binding private var sendMessage: String

    init(
        sendMessage: Binding<String>,
        callback: @escaping (String) -> Void
    ) {
        _sendMessage = sendMessage
        self.callback = callback
    }

    var body: some View {
        WebView(
            sendMessage: $sendMessage,
            url: URL(string: WebUpgradeAccountView.url)!,
            messageHandlers: [MessageHandler.ssi: callback]
        )
        .navigationBarHidden(true)
    }
}

#if DEBUG
struct WebUpgradeAccountView_Previews: PreviewProvider {
    static var previews: some View {
        WebUpgradeAccountView(
            sendMessage: .constant("Test Message"),
            callback: { print($0) }
        )
    }
}
#endif
