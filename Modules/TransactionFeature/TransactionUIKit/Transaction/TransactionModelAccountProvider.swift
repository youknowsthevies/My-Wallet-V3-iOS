// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import PlatformUIKit
import RxSwift

/// Types adopting `SourceAndTargetAccountProviding` should provide access to the source and destination account
public protocol SourceAndTargetAccountProviding: AccountPickerAccountProviding {
    var sourceAccount: Single<CryptoAccount?> { get }
    var destinationAccount: Observable<TransactionTarget?> { get }
}

class TransactionModelAccountProvider: SourceAndTargetAccountProviding {

    private let transactionModel: TransactionModel

    var accounts: Single<[BlockchainAccount]> {
        transactionModel.state
            .map(\.availableTargets)
            .first()
            .map { $0 as? [BlockchainAccount] ?? [] }
    }

    var sourceAccount: Single<CryptoAccount?> {
        transactionModel.state
            .compactMap { $0.source as? CryptoAccount }
            .take(1)
            .asSingle()
    }

    var destinationAccount: Observable<TransactionTarget?> {
        transactionModel.state
            .map(\.destination)
    }

    init(transactionModel: TransactionModel) {
        self.transactionModel = transactionModel
    }
}
