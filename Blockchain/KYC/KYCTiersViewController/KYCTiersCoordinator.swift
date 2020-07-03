//
//  KYCTiersCoordinator.swift
//  Blockchain
//
//  Created by Alex McGregor on 12/21/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift
import PlatformKit

class KYCTiersCoordinator {
    
    private let limitsAPI: TradeLimitsAPI = ExchangeServices().tradeLimits
    private var disposable: Disposable?
    private weak var interface: KYCTiersInterface?
    private let tiersService: KYCTiersServiceAPI
    
    init(interface: KYCTiersInterface?, tiersService: KYCTiersServiceAPI = KYCServiceProvider.default.tiers) {
        self.interface = interface
        self.tiersService = tiersService
    }
    
    func refreshViewModel(withCurrencyCode code: String = "USD", suppressCTA: Bool = false) {
        interface?.collectionViewVisibility(.hidden)
        interface?.loadingIndicator(.visible)
        
        let limitsObservable = limitsAPI.getTradeLimits(withFiatCurrency: code, ignoringCache: true)
            .optional()
            .catchErrorJustReturn(nil)
        
        disposable = Single
            .zip(
                tiersService.tiers,
                limitsObservable
            )
            .observeOn(MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] (response, limits) in
                guard let this = self else { return }
                let formatter: NumberFormatter = NumberFormatter.localCurrencyFormatterWithGroupingSeparator
                let max = NSDecimalNumber(decimal: limits?.maxTradableToday ?? 0)
                let header = KYCTiersHeaderViewModel.make(
                    with: response,
                    availableFunds: formatter.string(from: max),
                    suppressDismissCTA: suppressCTA
                )
                let filtered = response.tiers.filter({ $0.tier != .tier0 })
                let cells = filtered.map({ KYCTierCellModel.model(from: $0) }).compactMap({ $0 })
                
                let page = KYCTiersPageModel(header: header, cells: cells)
                this.interface?.apply(page)
                this.interface?.loadingIndicator(.hidden)
                this.interface?.collectionViewVisibility(.visible)
            }, onError: { [weak self] _ in
                guard let this = self else { return }
                this.interface?.loadingIndicator(.hidden)
                this.interface?.collectionViewVisibility(.visible)
            })
    }
}
