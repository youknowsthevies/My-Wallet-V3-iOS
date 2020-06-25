//
//  StellarActivityItemEventDetailsFetcherAPIMock.swift
//  BlockchainTests
//
//  Created by Paulo on 21/05/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxSwift
import StellarKit

class StellarActivityItemEventDetailsFetcherAPIMock: ActivityItemEventDetailsFetcherAPI {
    typealias Model = StellarActivityItemEventDetails

    func details(for identifier: String) -> Observable<StellarActivityItemEventDetails> {
        .error(NSError())
    }
}
