// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import WalletConnectSwift

struct WalletConnectSession: Codable {

    let url: String
    let dAppInfo: DAppInfo
    let walletInfo: WalletInfo

    struct WalletInfo: Codable {
        let clientId: String
        let sourcePlatform: String
    }

    struct DAppInfo: Codable {
        let peerId: String
        let peerMeta: ClientMeta
        let chainId: Int?
    }

    struct ClientMeta: Codable {
        let description: String
        let url: String
        let icons: [String]
        let name: String
    }

    init(session: Session) {
        url = session.url.absoluteString
        dAppInfo = DAppInfo(
            peerId: session.dAppInfo.peerId,
            peerMeta: ClientMeta(
                description: session.dAppInfo.peerMeta.description ?? "",
                url: session.dAppInfo.peerMeta.url.absoluteString,
                icons: session.dAppInfo.peerMeta.icons.map(\.absoluteString),
                name: session.dAppInfo.peerMeta.name
            ),
            chainId: session.dAppInfo.chainId
        )
        walletInfo = WalletInfo(
            clientId: session.walletInfo?.peerId ?? UUID().uuidString,
            sourcePlatform: "ios"
        )
    }
}

extension WalletConnectSession {
    func isEqual(_ rhs: Self) -> Bool {
        url == rhs.url
    }
}
