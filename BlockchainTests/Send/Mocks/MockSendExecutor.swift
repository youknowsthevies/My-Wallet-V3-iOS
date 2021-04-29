// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import PlatformKit
import RxSwift

@testable import Blockchain

final class MockSendExecutor: SendExecuting {
    
    private let expectedResult: Result<Void, Error>
    
    init(expectedResult: Result<Void, Error>) {
        self.expectedResult = expectedResult
    }
    
    func fetchHistoryIfNeeded() {}
    func send(value: CryptoValue, to address: String) -> Single<Void> {
        switch expectedResult {
        case .success:
            return .just(Void())
        case .failure(let error):
            return Single.error(error)
        }
    }
}
