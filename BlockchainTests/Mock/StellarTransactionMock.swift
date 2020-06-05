//
//  StellarTransactionMock.swift
//  BlockchainTests
//
//  Created by Paulo on 04/06/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import StellarKit
@testable import Blockchain

class StellarTransactionMock: StellarTransactionAPI {
    typealias CompletionHandler = ((Result<Bool, Error>) -> Void)
    typealias AccountID = String

    func send(_ paymentOperation: StellarPaymentOperation, sourceKeyPair: StellarKit.StellarKeyPair) -> Completable {
        return Completable.empty()
    }

    func get(transaction transactionHash: String, completion: @escaping ((Result<StellarTransactionResponse, Error>) -> Void)) {
        completion(.failure(NSError()))
    }
}
