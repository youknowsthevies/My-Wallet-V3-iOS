//
//  ActivityDetailsPresenterFactory.swift
//  Blockchain
//
//  Created by Paulo on 04/05/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import PlatformUIKit
import RxRelay
import RxSwift

final class ActivityDetailsPresenterFactory {

    static func presenter(for event: ActivityItemEvent,
                          router: ActivityRouterAPI,
                          paxServiceProvider: PAXServiceProvider = PAXServiceProvider.shared) -> DetailsScreenPresenterAPI {
        switch event {
        case .buy(let buy):
            return BuyActivityDetailsPresenter(event: buy)
        case .swap(let swap):
            return SwapActivityDetailsPresenter(event: swap)
        case .transactional(let transactional):
            switch transactional.currency {
            case .bitcoin:
                return BitcoinActivityDetailsPresenter(event: transactional, router: router)
            case .bitcoinCash:
                return BitcoinCashActivityDetailsPresenter(event: transactional, router: router)
            case .pax:
                let interactor = ERC20ActivityDetailsInteractor(cryptoCurrency: transactional.currency)
                return ERC20ActivityDetailsPresenter(event: transactional, router: router, interactor: interactor)
            case .stellar:
                return StellarActivityDetailsPresenter(event: transactional, router: router)
            case .ethereum:
                return EthereumActivityDetailsPresenter(event: transactional, router: router)
            }
        }
    }
}
