// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import FeatureCardIssuingDomain
import Foundation

final class ResidentialAddressRepository: ResidentialAddressRepositoryAPI {

    private let client: ResidentialAddressClientAPI

    init(client: ResidentialAddressClientAPI) {
        self.client = client
    }

    func fetchResidentialAddress() -> AnyPublisher<Card.Address, NabuNetworkError> {
        client.fetchResidentialAddress()
    }

    func update(residentialAddress: Card.Address) -> AnyPublisher<Card.Address, NabuNetworkError> {
        client.update(residentialAddress: residentialAddress)
    }
}
