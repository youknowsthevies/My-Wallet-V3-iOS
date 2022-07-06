// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors

public protocol ReferralRepositoryAPI {
    func fetchReferralCampaign(for currency: String) -> AnyPublisher<Referral, NetworkError>
    func createReferral(with code: String) -> AnyPublisher<Void, NetworkError>
}
