//
//  TransactionModelAccountProvider.swift
//  TransactionUIKit
//
//  Created by Paulo on 06/11/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import PlatformUIKit
import RxSwift

class TransactionModelAccountProvider: AccountPickerAccountProviding {

    private let transactionModel: TransactionModel

    var accounts: Single<[BlockchainAccount]> {
        transactionModel.state
            .map(\.availableTargets)
            .first()
            .map { $0 as? [BlockchainAccount] ?? [] }
    }

    init(transactionModel: TransactionModel) {
        self.transactionModel = transactionModel
    }
}
