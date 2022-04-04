// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import ComposableArchitecture
import FeatureCardIssuingDomain
import FeatureCardIssuingUI
import FeatureSettingsUI
import Foundation
import PlatformKit
import SwiftUI

final class CardIssuingAdapter: FeatureSettingsUI.CardIssuingViewControllerAPI {

    private let nabuUserService: NabuUserServiceAPI
    private let cardIssuingBuilder: CardIssuingBuilderAPI

    init(
        cardIssuingBuilder: CardIssuingBuilderAPI,
        nabuUserService: NabuUserServiceAPI
    ) {
        self.cardIssuingBuilder = cardIssuingBuilder
        self.nabuUserService = nabuUserService
    }

    func makeViewController(
        onComplete: @escaping (FeatureSettingsUI.CardOrderingResult) -> Void
    ) -> UIViewController {
        let address = nabuUserService
            .user
            .mapError { _ in CardOrderingError.noAddress }
            .flatMap { user -> AnyPublisher<Card.Address, CardOrderingError> in
                guard let address = user.address else {
                    return .failure(.noAddress)
                }
                return .just(Card.Address(with: address))
            }
            .eraseToAnyPublisher()

        return cardIssuingBuilder.makeIntroViewController(address: address) { result in
            switch result {
            case .created:
                onComplete(.created)
            case .cancelled:
                onComplete(.cancelled)
            }
        }
    }
}

extension FeatureCardIssuingDomain.Card.Address {
    init(with address: UserAddress) {
        self.init(
            line1: address.lineOne,
            line2: address.lineTwo,
            city: address.city,
            postcode: address.postalCode,
            state: address.state,
            country: address.country.code
        )
    }
}
