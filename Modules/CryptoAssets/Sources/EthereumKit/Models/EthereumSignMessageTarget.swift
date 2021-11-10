// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import PlatformKit

public struct EthereumSignMessageTarget: WalletConnectTarget {

    // MARK: - Public Properties

    public let onTxCompleted: TxCompleted
    public let dAppAddress: String
    public let dAppName: String
    public let currencyType: CurrencyType = .crypto(.coin(.ethereum))
    public let account: String
    public let message: Data
    public var label: String {
        dAppName
    }

    public init(
        dAppAddress: String,
        dAppName: String,
        account: String,
        message: Data,
        onTxCompleted: @escaping TxCompleted
    ) {
        self.onTxCompleted = onTxCompleted
        self.dAppAddress = dAppAddress
        self.dAppName = dAppName
        self.account = account
        self.message = message
    }
}
