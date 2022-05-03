// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureWalletConnectDomain
import WalletConnectSwift

final class SwitchRequestHandler: RequestHandler {

    private enum Method: String {
        case sendRawTransaction = "wallet_switchEthereumChain"
    }

    private let responseEvent: (WalletConnectResponseEvent) -> Void

    init(responseEvent: @escaping (WalletConnectResponseEvent) -> Void) {
        self.responseEvent = responseEvent
    }

    func canHandle(request: Request) -> Bool {
        Method(rawValue: request.method) != nil
    }

    func handle(request: Request) {
        responseEvent(.rejected(request))
    }
}
