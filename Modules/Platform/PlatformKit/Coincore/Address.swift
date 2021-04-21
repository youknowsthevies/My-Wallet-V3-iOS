//
//  Address.swift
//  PlatformKit
//
//  Created by Paulo on 30/07/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

public enum TransactionResult {
    case hashed(txHash: String, amount: MoneyValue)
    case unHashed(amount: MoneyValue)
}

public protocol TransactionTarget {
    
    typealias TxCompleted = (TransactionResult) -> Completable
    
    var label: String { get }
    /// onTxCompleted should be used by CryptoInterestAccount and CustodialTradingAccount,
    /// it should POST to "payments/deposits/pending", check Android
    var onTxCompleted: TxCompleted { get }
}

public extension TransactionTarget {
    var onTxCompleted: TxCompleted {
        { _ in Completable.empty() }
    }
}

public protocol ReceiveAddress: TransactionTarget {
    var address: String { get }
    var memo: String? { get }
}

public extension ReceiveAddress {
    var memo: String? {
        nil
    }
}

public protocol InvoiceTarget { }

public protocol CryptoTarget: TransactionTarget {
    var asset: CryptoCurrency { get }
}

public protocol CryptoReceiveAddress: ReceiveAddress, CryptoTarget { }

public protocol CryptoAssetQRMetadataProviding {
    var metadata: CryptoAssetQRMetadata { get }
}

public enum ReceiveAddressError: Error {
    case notSupported
}
