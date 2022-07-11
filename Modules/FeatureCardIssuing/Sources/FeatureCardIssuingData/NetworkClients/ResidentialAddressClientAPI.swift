// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import FeatureCardIssuingDomain
import Foundation
import NetworkKit

protocol ResidentialAddressClientAPI {

    func fetchResidentialAddress() -> AnyPublisher<Card.Address, NabuNetworkError>
    func update(residentialAddress: Card.Address) -> AnyPublisher<Card.Address, NabuNetworkError>
}
