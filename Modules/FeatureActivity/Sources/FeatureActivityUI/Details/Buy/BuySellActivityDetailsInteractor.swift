// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import FeatureCardPaymentDomain
import MoneyKit
import PlatformKit

final class BuySellActivityDetailsInteractor {

    private let cardListService: CardListServiceAPI
    private let ordersService: OrdersServiceAPI

    init(
        cardListService: CardListServiceAPI = resolve(),
        ordersService: OrdersServiceAPI = resolve()
    ) {
        self.cardListService = cardListService
        self.ordersService = ordersService
    }

    func fetchCardDetails(for paymentMethodId: String?) -> AnyPublisher<CardData?, Never> {
        cardListService
            .card(by: paymentMethodId ?? "")
    }

    func fetchPrice(for orderId: String) -> AnyPublisher<MoneyValue?, OrdersServiceError> {
        ordersService
            .fetchOrder(with: orderId)
            .map(\.price)
            .eraseToAnyPublisher()
    }
}
