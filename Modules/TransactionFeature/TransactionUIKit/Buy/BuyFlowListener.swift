// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine

protocol BuyFlowListening: AnyObject {
    func buyFlowDidComplete(with result: TransactionFlowResult)
}

final class BuyFlowListener: BuyFlowListening {

    var publisher: AnyPublisher<TransactionFlowResult, Never> {
        subject.eraseToAnyPublisher()
    }

    private let subject = PassthroughSubject<TransactionFlowResult, Never>()

    deinit {
        subject.send(completion: .finished)
    }

    func buyFlowDidComplete(with result: TransactionFlowResult) {
        subject.send(result)
    }
}
