// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import PlatformUIKit
import RxSwift

/// Types adopting `SourceAndTargetAccountProviding` should provide access to the source and destination account
public protocol SourceAndTargetAccountProviding: AccountPickerAccountProviding {
    var sourceAccount: Single<BlockchainAccount?> { get }
    var destinationAccount: Observable<TransactionTarget?> { get }
}

class TransactionModelAccountProvider: SourceAndTargetAccountProviding {

    private let transactionModel: TransactionModel

    var accounts: Observable<[BlockchainAccount]> {
        transactionModel.state
            .map { state -> [BlockchainAccount] in
                switch state.source {
                case .none:
                    return state.availableSources
                case .some:
                    return state.availableTargets as? [BlockchainAccount] ?? []
                }
            }
    }

    var sourceAccount: Single<BlockchainAccount?> {
        transactionModel.state
            .map(\.source)
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
