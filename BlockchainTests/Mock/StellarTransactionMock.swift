// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import Blockchain
import RxSwift
import StellarKit

class StellarTransactionMock: StellarTransactionAPI {
    typealias CompletionHandler = ((Result<Bool, Error>) -> Void)
    typealias AccountID = String

    func send(_ paymentOperation: StellarPaymentOperation, sourceKeyPair: StellarKit.StellarKeyPair) -> Completable {
        Completable.empty()
    }

    func get(transaction transactionHash: String, completion: @escaping ((Result<StellarTransactionResponse, Error>) -> Void)) {
        completion(.failure(NSError()))
    }
}
