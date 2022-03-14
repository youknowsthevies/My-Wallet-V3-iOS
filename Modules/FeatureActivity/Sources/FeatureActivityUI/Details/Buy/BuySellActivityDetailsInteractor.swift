// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import FeatureCardPaymentDomain
import MoneyKit
import PlatformKit
import RxSwift

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

    func fetchCardDetails(for paymentMethodId: String?) -> Single<CardData?> {
        cardListService
            .card(by: paymentMethodId ?? "")
            .asSingle()
    }

    func fetchPrice(for orderId: String) -> Single<MoneyValue?> {
        ordersService
            .fetchOrder(with: orderId)
            .map(\.price)
    }
}
