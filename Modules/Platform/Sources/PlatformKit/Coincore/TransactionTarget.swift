// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxSwift

public enum TransactionResult {
    case signed(rawTx: String)
    case hashed(txHash: String, amount: MoneyValue, order: OrderDetails? = nil)
    case unHashed(amount: MoneyValue)
}

public protocol TransactionTarget: Account {

    typealias TxCompleted = (TransactionResult) -> Completable

    /// onTxCompleted should be used by CryptoInterestAccount and CustodialTradingAccount,
    /// it should POST to "payments/deposits/pending", check Android
    var onTxCompleted: TxCompleted { get }
}

extension TransactionTarget {
    public var onTxCompleted: TxCompleted {
        { _ in Completable.empty() }
    }
}

public protocol CryptoTarget: TransactionTarget {
    var asset: CryptoCurrency { get }
}

extension CryptoTarget {

    public var currencyType: CurrencyType {
        asset.currencyType
    }
}
