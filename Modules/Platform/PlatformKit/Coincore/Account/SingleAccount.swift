// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxSwift
import ToolKit

/// A BlockchainAccount that represents a single account, opposed to a collection of accounts.
public protocol SingleAccount: BlockchainAccount, TransactionTarget {
    var currencyType: CurrencyType { get }
    var accountType: SingleAccountType { get }
    var isDefault: Bool { get }
    var sourceState: Single<SourceState> { get }
}

public extension SingleAccount {
    var actionableBalance: Single<MoneyValue> {
        balance
    }
    var receiveAddress: Single<ReceiveAddress> {
        .error(ReceiveAddressError.notSupported)
    }

    var sourceState: Single<SourceState> {
        .just(.notSupported)
    }
}
