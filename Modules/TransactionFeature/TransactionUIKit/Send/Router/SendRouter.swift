// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformKit
import PlatformUIKit
import TransactionKit

final class SendRouter: SendRouterAPI {
    
    private let sendProvider: SendScreenProvider
    private let navigationRouter: NavigationRouterAPI
    
    init(navigationRouter: NavigationRouterAPI = NavigationRouter(),
         sendProvider: SendScreenProvider = resolve()) {
        self.navigationRouter = navigationRouter
        self.sendProvider = sendProvider
    }
    
    func send(account: BlockchainAccount) {
        guard let account = account as? CryptoAccount else {
            return
        }
        let viewController = sendProvider.send(account.asset)
        navigationRouter.present(viewController: viewController, using: .modalOverTopMost)
    }
}
