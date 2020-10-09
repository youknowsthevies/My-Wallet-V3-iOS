//
//  ReceiveRouterAPI.swift
//  TransactionKit
//
//  Created by Paulo on 01/09/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit

public protocol ReceiveRouterAPI: AnyObject {
    func presentReceiveScreen(for account: BlockchainAccount)
    func shareDetails(for metadata: CryptoAssetQRMetadata)
}
