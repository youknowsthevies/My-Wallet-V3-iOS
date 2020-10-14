//
//  KYCTiersCoordinator.swift
//  Blockchain
//
//  Created by Alex McGregor on 12/21/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import PlatformKit
import RxSwift

class KYCTiersCoordinator {

    private let limitsAPI: TradeLimitsAPI = resolve()
    private var disposable: Disposable?
    private weak var interface: KYCTiersInterface?
    private let tiersService: KYCTiersServiceAPI

    init(interface: KYCTiersInterface?, tiersService: KYCTiersServiceAPI = resolve()) {
        self.interface = interface
        self.tiersService = tiersService
    }

    func refreshViewModel(withCurrency currency: FiatCurrency = .USD, suppressCTA: Bool = false) {
        interface?.collectionViewVisibility(.hidden)
        interface?.loadingIndicator(.visible)

        let tradeLimits = limitsAPI.getTradeLimits(withFiatCurrency: currency.code, ignoringCache: true)
            .optional()
            .catchErrorJustReturn(nil)
        let tiers = tiersService.tiers

        disposable = Single.zip(tradeLimits, tiers)
            .map { (values) -> (FiatValue, KYC.UserTiers) in
                let (tradeLimits, tiers) = values
                guard tiers.tierAccountStatus(for: .tier1).isApproved else {
                    return (FiatValue.zero(currency: currency), tiers)
                }
                let maxTradableToday = FiatValue.create(
                    major: tradeLimits?.maxTradableToday ?? 0,
                    currency: currency
                )
                return (maxTradableToday, tiers)
            }
            .observeOn(MainScheduler.instance)
            .subscribe(
                onSuccess: { [weak self] (maxTradableToday, tiers) in
                    guard let this = self else { return }
                    let header = KYCTiersHeaderViewModel.make(
                        with: tiers,
                        availableFunds: maxTradableToday.toDisplayString(includeSymbol: true),
                        suppressDismissCTA: suppressCTA
                    )

                    let models = tiers.tiers
                        .filter { $0.tier != .tier0 }
                        .map { KYCTierCellModel.model(from: $0) }
                        .compactMap { $0 }

                    let page = KYCTiersPageModel(header: header, cells: models)
                    this.interface?.apply(page)
                    this.interface?.loadingIndicator(.hidden)
                    this.interface?.collectionViewVisibility(.visible)
                },
                onError: { [weak self] _ in
                    guard let this = self else { return }
                    this.interface?.loadingIndicator(.hidden)
                    this.interface?.collectionViewVisibility(.visible)
                }
            )
    }
}
