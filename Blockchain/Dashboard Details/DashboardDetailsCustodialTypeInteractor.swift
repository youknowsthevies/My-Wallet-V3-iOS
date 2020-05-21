//
//  DashboardDetailsCellTypePresenter.swift
//  Blockchain
//
//  Created by AlexM on 2/14/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay
import PlatformKit
import PlatformUIKit

final class DashboardDetailsCustodialTypeInteractor {

    var exists: Observable<Bool> {
        existanceRelay.distinctUntilChanged()
    }
    
    private let existanceRelay = BehaviorRelay(value: false)
    private let disposeBag = DisposeBag()
    
    init(balanceFetcher: CustodialAccountBalanceFetching) {
        balanceFetcher.isFunded
            .asObservable()
            .bind(to: existanceRelay)
            .disposed(by: disposeBag)
    }
}
