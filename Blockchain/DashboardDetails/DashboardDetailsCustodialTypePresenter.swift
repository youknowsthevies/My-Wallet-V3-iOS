//
//  DashboardDetailsCellTypePresenter.swift
//  Blockchain
//
//  Created by AlexM on 2/14/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import PlatformUIKit
import RxCocoa
import RxRelay
import RxSwift

enum CustodialCellTypeAction {
    /// Show the `CurrentBalanceTableViewCell`
    case show
    
    /// Do not show the `CurrentBalanceTableViewCell`
    /// NOTE: Hiding is not supported as there is no
    /// use case for it.
    case none
}

/// Provides a `CustodialCellTypeAction` that dictates whether or not to show
/// the `CurrentBalanceTableViewCell` for a `custodial` wallet. This call is
/// asynchronous so rather than delay presenting the details screen, we make this call
/// on `setup()` and insert the cell once whether or not the wallet has been funded is
/// determined.
final class DashboardDetailsCustodialTypePresenter {
    
    typealias Action = CustodialCellTypeAction
    
    var action: Driver<Action> {
        actionRelay
            .asDriver()
            .distinctUntilChanged()
    }
    
    var actionObservable: Observable<Action> {
        actionRelay.asObservable()
    }
    
    private let actionRelay = BehaviorRelay<Action>(value: .none)
    private let disposeBag = DisposeBag()
    private unowned let balanceFetching: CustodialAccountBalanceFetching
    
    init(balanceFetching: CustodialAccountBalanceFetching) {
        self.balanceFetching = balanceFetching
        
        let custodialFundedObservable = balanceFetching.isFunded.asObservable()
        
        custodialFundedObservable
            .map { $0 ? .show : .none }
            .bindAndCatch(to: actionRelay)
            .disposed(by: disposeBag)
    }
}
