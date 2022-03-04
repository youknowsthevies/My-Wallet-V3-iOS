// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation
import MoneyKit
import PlatformKit

public struct EthereumSendTransactionTarget: WalletConnectTarget {

    public enum Method {
        case sign
        case send
    }

    // MARK: - Public Properties

    public let onTxCompleted: TxCompleted
    public let onTransactionRejected: () -> AnyPublisher<Void, Never>
    public let currencyType: CurrencyType = .crypto(.ethereum)
    public var label: String {
        dAppName
    }

    // MARK: - Properties

    let method: Method
    let dAppAddress: String
    let dAppName: String
    let dAppLogoURL: String
    let transaction: EthereumJsonRpcTransaction

    // MARK: - Init

    public init(
        dAppAddress: String,
        dAppName: String,
        dAppLogoURL: String,
        transaction: EthereumJsonRpcTransaction,
        method: Method,
        onTxCompleted: @escaping TxCompleted,
        onTransactionRejected: @escaping () -> AnyPublisher<Void, Never>
    ) {
        self.onTxCompleted = onTxCompleted
        self.onTransactionRejected = onTransactionRejected
        self.dAppAddress = dAppAddress
        self.dAppName = dAppName
        self.dAppLogoURL = dAppLogoURL
        self.transaction = transaction
        self.method = method
    }
}
