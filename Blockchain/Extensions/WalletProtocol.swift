// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

@objc
protocol WalletProtocol: class {
    
    var isBitcoinWalletFunded: Bool { get }
    
    @objc var isNew: Bool { get set }
    @objc var delegate: WalletDelegate! { get set }

    @objc func isInitialized() -> Bool
}
