// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformKit
import RxRelay
import RxSwift

public final class AssetBalanceViewInteractor: AssetBalanceViewInteracting {

    public typealias InteractionState = AssetBalanceViewModel.State.Interaction

    // MARK: - Exposed Properties

    public var state: Observable<InteractionState> {
        _ = setup
        return stateRelay.asObservable()
    }

    // MARK: - Private Accessors

    private lazy var setup: Void = {
        assetBalanceFetching.calculationState
            .map { state -> InteractionState in
                switch state {
                case .calculating, .invalid:
                    return .loading
                case .value(let result):
                    return .loaded(
                        next: .init(
                            fiatValue: result.quote,
                            cryptoValue: result.base,
                            pendingValue: .zero(currency: result.base.currency)
                        )
                    )
                }
            }
            .bindAndCatch(to: stateRelay)
            .disposed(by: disposeBag)
    }()

    private let stateRelay = BehaviorRelay<InteractionState>(value: .loading)
    private let disposeBag = DisposeBag()

    private let assetBalanceFetching: AssetBalanceFetching

    // MARK: - Setup

    public init(assetBalanceFetching: AssetBalanceFetching) {
        self.assetBalanceFetching = assetBalanceFetching
    }
}
