// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxSwift
import XCTest

@testable import Blockchain
@testable import PlatformKit

class MockBlockchainDataRepository: BlockchainDataRepository {

    var mockNabuUser: NabuUser?

    init() {
        super.init()
    }
    
    override var nabuUserSingle: Single<NabuUser> {
        if let mock = mockNabuUser {
            return .just(mock)
        }
        return super.nabuUserSingle
    }

    override func fetchNabuUser() -> Single<NabuUser> {
        if let mock = mockNabuUser {
            return Single.just(mock)
        }
        return super.fetchNabuUser()
    }
}
