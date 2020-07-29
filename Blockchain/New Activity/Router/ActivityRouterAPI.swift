//
//  ActivityRouterAPI.swift
//  Blockchain
//
//  Created by Daniel Huri on 16/03/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import PlatformUIKit

protocol ActivityRouterAPI: AnyObject {
    func showWalletSelectionScreen()
    func showTransactionScreen(with event: ActivityItemEvent)
    func showBlockchainExplorer(for event: TransactionalActivityItemEvent)
}
