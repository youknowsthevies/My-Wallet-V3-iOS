// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureWalletConnectDomain
import Foundation
import Localization
import UIComponentsKit
import UIKit
import WalletConnectSwift

public struct DAppListState: Equatable {
    public static func == (lhs: DAppListState, rhs: DAppListState) -> Bool {
        lhs.sessions == rhs.sessions
    }

    struct DAppViewState: Equatable, Identifiable {
        var id: String
        let imageResource: ImageResource?
        let name: String
        let domain: String
    }

    var sessions: [WalletConnectSession] = []
    var title = String(format: LocalizationConstants.WalletConnect.connectedAppsCount, 0)
}

extension DAppListState.DAppViewState {
    init(session: WalletConnectSession) {
        let image: ImageResource?
        if let icon = session.dAppInfo.peerMeta.icons.first,
           let url = URL(string: icon)
        {
            image = .remote(url: url)
        } else {
            image = nil
        }

        id = session.dAppInfo.peerId
        imageResource = image
        name = session.dAppInfo.peerMeta.name
        domain = session.dAppInfo.peerMeta.url
    }
}

extension WalletConnectSession: Identifiable {
    public var id: String { url }
}
