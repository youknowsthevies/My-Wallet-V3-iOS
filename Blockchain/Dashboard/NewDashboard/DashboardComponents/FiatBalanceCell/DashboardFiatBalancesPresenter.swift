//
//  DashboardFiatBalancesPresenter.swift
//  Blockchain
//
//  Created by Daniel on 14/07/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformUIKit
import BuySellUIKit
import RxCocoa
import RxRelay
import RxSwift

final class DashboardFiatBalancesPresenter {
    
    // MARK: - Exposed Properties
    
    /// Streams only distinct actions
    var action: Driver<DashboardItemDisplayAction<FiatBalanceCollectionViewPresenter>> {
        _ = setup
        return actionRelay
            .asDriver()
            .distinctUntilChanged()
    }
    
    // MARK: - Private Properties
    
    private let actionRelay = BehaviorRelay<DashboardItemDisplayAction<FiatBalanceCollectionViewPresenter>>(value: .hide)
    
    private let fiatBalanceCollectionViewPresenter: FiatBalanceCollectionViewPresenter    
    private let interactor: DashboardFiatBalancesInteractor
    private let disposeBag = DisposeBag()
    
    private lazy var setup: Void = {
        let fiatBalanceCollectionViewPresenter = self.fiatBalanceCollectionViewPresenter
        interactor.shouldAppear
            .map { $0 ? .show(fiatBalanceCollectionViewPresenter) : .hide }
            .bindAndCatch(to: actionRelay)
            .disposed(by: disposeBag)
    }()
    
    // MARK: - Setup
    
    init(interactor: DashboardFiatBalancesInteractor) {
        self.interactor = interactor
        
        fiatBalanceCollectionViewPresenter = FiatBalanceCollectionViewPresenter(
            interactor: interactor.fiatBalanceCollectionViewInteractor
        )
    }

    func refresh() {
        fiatBalanceCollectionViewPresenter.refresh()
    }
}
