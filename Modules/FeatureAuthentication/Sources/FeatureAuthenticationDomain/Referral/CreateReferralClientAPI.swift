// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import Foundation

public protocol CheckReferralClientAPI {
    func checkReferral(with code: String) -> AnyPublisher<Void, NetworkError>
}
