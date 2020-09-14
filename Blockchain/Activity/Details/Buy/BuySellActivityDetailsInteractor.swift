//
//  BuySellActivityDetailsInteractor.swift
//  Blockchain
//
//  Created by Paulo on 09/06/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import BuySellKit
import PlatformKit
import RxSwift

final class BuySellActivityDetailsInteractor {

    private let cardListService: CardListServiceAPI

    convenience init(cardsServiceProvider: CardServiceProviderAPI = CardServiceProvider.default) {
        self.init(cardListService: cardsServiceProvider.cardList)
    }

    init(cardListService: CardListServiceAPI) {
        self.cardListService = cardListService
    }

    func fetchCardDetails(for paymentMethodId: String?) -> Single<CardData?> {
        cardListService
            .card(by: paymentMethodId ?? "")
    }
}
