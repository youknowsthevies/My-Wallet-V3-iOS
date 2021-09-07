// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import RxSwift

/// Brokerage (Simple Buy/Sell/Swap) Eligibility Service
public protocol EligibilityServiceAPI: AnyObject {

    /// Feature is enabled and EligibilityClientAPI returns eligible for current fiat currency.
    var isEligible: Single<Bool> { get }

    var isEligiblePublisher: AnyPublisher<Bool, Never> { get }

    func fetch() -> Single<Bool>
}
