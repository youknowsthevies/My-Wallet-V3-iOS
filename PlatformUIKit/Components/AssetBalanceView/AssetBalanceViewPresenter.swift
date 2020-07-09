//
//  AssetBalanceViewPresenter.swift
//  PlatformUIKit
//
//  Created by AlexM on 10/31/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxCocoa
import RxRelay
import RxSwift

public final class AssetBalanceViewPresenter {
    
    typealias PresentationState = DashboardAsset.State.AssetBalance.Presentation
        
    // MARK: - Exposed Properties
    
    var state: Observable<PresentationState> {
        _ = setup
        return stateRelay
            .observeOn(MainScheduler.instance)
    }
    
    var alignment: Driver<UIStackView.Alignment> {
        alignmentRelay.asDriver()
    }
    
    // MARK: - Injected
    
    private lazy var setup: Void = {
        /// Map interaction state into presnetation state
        /// and bind it to `stateRelay`
        interactor.state
            .map(weak: self) { (self, state) in
                .init(with: state, descriptors: self.descriptors)
            }
            .bindAndCatch(to: stateRelay)
            .disposed(by: disposeBag)
    }()
    
    private let interactor: AssetBalanceViewInteracting
    private let descriptors: DashboardAsset.Value.Presentation.AssetBalance.Descriptors
    
    // MARK: - Private Accessors
    
    private let alignmentRelay: BehaviorRelay<UIStackView.Alignment>
    private let stateRelay = BehaviorRelay<PresentationState>(value: .loading)
    private let disposeBag = DisposeBag()
    
    // MARK: - Setup
    
    public init(alignment: UIStackView.Alignment = .fill,
                interactor: AssetBalanceViewInteracting,
                descriptors: DashboardAsset.Value.Presentation.AssetBalance.Descriptors) {
        self.interactor = interactor
        self.descriptors = descriptors
        self.alignmentRelay = BehaviorRelay<UIStackView.Alignment>(value: alignment)
    }
}
