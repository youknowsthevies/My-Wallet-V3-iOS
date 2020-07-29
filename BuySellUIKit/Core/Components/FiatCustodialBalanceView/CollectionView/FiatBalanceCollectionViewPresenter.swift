//
//  FiatBalanceCollectionViewPresenter.swift
//  PlatformUIKit
//
//  Created by Daniel on 13/07/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxCocoa
import RxRelay
import RxSwift

public final class FiatBalanceCollectionViewPresenter {
    
    // MARK: - Exposed Properties
    
    var presenters: Driver<[FiatCustodialBalanceViewPresenter]> {
        _ = setup
        return presentersRelay.asDriver()
    }
    
    public var tap: Signal<CurrencyType> {
        tapRelay
            .asSignal()
    }
    
    // MARK: - Injected Properties
    
    private let interactor: FiatBalanceCollectionViewInteractor
    
    // MARK: - Accessors
    
    private let tapRelay = PublishRelay<CurrencyType>()
    private let presentersRelay = BehaviorRelay<[FiatCustodialBalanceViewPresenter]>(value: [])
    private let disposeBag = DisposeBag()
    
    private lazy var setup: Void = {
        interactor.interactors
            .map { interactors in
                interactors.map {
                    FiatCustodialBalanceViewPresenter(
                        interactor: $0,
                        descriptors: .dashboard(),
                        respondsToTaps: false,
                        presentationStyle: interactors.count > 1 ? .border : .plain
                    )
                }
            }
            .bindAndCatch(to: presentersRelay)
            .disposed(by: disposeBag)
    }()
    
    // MARK: - Setup
    
    public init(interactor: FiatBalanceCollectionViewInteractor) {
        self.interactor = interactor
    }
    
    // MARK: - Public
    
    public func selected(currencyType: CurrencyType) {
        tapRelay.accept(currencyType)
    }
    
    public func refresh() {
        _ = setup
        interactor.refresh()
    }
}

extension FiatBalanceCollectionViewPresenter: Equatable {
    public static func == (lhs: FiatBalanceCollectionViewPresenter, rhs: FiatBalanceCollectionViewPresenter) -> Bool {
        lhs.interactor.interactorsStateRelay.value == rhs.interactor.interactorsStateRelay.value
    }
}
