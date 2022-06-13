// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import FeatureReferralDomain
import Foundation

public protocol ReferralAdapterAPI {
    func hasReferral() -> AnyPublisher<Referral?, Never>
}
