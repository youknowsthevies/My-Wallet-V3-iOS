//
//  DashboardFiatBalancesPresenter.swift
//  Blockchain
//
//  Created by Daniel on 14/07/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import PlatformUIKit
import RxCocoa
import RxRelay
import RxSwift

final class DashboardFiatBalancesPresenter {
    
    // MARK: - Exposed Properties
    
    var tap: Driver<DashboardItemDisplayAction<CurrencyType>> {
        selectionRelay
            .asDriver()
    }
    
    /// Streams only distinct actions
    var action: Driver<DashboardItemDisplayAction<FiatBalanceCollectionViewPresenter>> {
        actionRelay
            .asDriver()
            .distinctUntilChanged()
    }
    
    // MARK: - Private Properties
    
    let actionRelay = BehaviorRelay<DashboardItemDisplayAction<FiatBalanceCollectionViewPresenter>>(value: .hide)
    private let selectionRelay = BehaviorRelay<DashboardItemDisplayAction<CurrencyType>>(value: .hide)
    private let fiatBalanceCollectionViewPresenter: FiatBalanceCollectionViewPresenter    
    private let interactor: DashboardFiatBalancesInteractor
    private let disposeBag = DisposeBag()
    
    // MARK: - Setup
    
    init(interactor: DashboardFiatBalancesInteractor) {
        self.interactor = interactor
        
        fiatBalanceCollectionViewPresenter = FiatBalanceCollectionViewPresenter(
            interactor: interactor.fiatBalanceCollectionViewInteractor
        )
        
        fiatBalanceCollectionViewPresenter
            .tap
            .emit(onNext: { [weak self] currencyType in
                guard let self = self else { return }
                self.selectionRelay.accept(.show(currencyType))
            })
            .disposed(by: disposeBag)
    }
    
    func refresh() {
        interactor.shouldAppear
            .subscribe(onSuccess: { [weak self] shouldAppear in
                if shouldAppear {
                    self?.displayBalancesCollection()
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func displayBalancesCollection() {
        actionRelay.accept(.show(fiatBalanceCollectionViewPresenter))
    }
}
