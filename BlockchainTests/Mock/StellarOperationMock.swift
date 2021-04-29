// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import Blockchain
import RxSwift

class StellarOperationMock: StellarOperationsAPI {

    var operations: Observable<[Blockchain.StellarOperation]> = .just([])

    func isStreaming() -> Bool { true }

    func end() { }

    func clear() { }
}
