// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformKit
import RxRelay
import RxSwift

public final class AssetBalanceTypeViewInteractor: AssetBalanceTypeViewInteracting {

    public typealias InteractionState = AssetBalanceViewModel.State.Interaction
    private typealias Model = AssetBalanceViewModel.Value.Interaction

    // MARK: - Exposed Properties

    public let accountType: SingleAccountType

    public var state: Observable<InteractionState> {
        _ = setup
        return stateRelay.asObservable()
    }

    // MARK: - Private Accessors

    private lazy var setup: Void = {
        Observable.combineLatest(
                assetBalanceFetching.calculationState,
                assetBalanceFetching.wallet.pendingBalanceMoneyObservable,
                assetBalanceFetching.trading.pendingBalanceMoneyObservable,
                assetBalanceFetching.savings.pendingBalanceMoneyObservable
            )
            .map(weak: self) { (self, values) -> InteractionState in
                let (state, wallet, trading, savings) = values
                let pending: MoneyValue
                switch self.accountType {
                case .custodial(let type):
                    switch type {
                    case .savings:
                        pending = savings
                    case .trading:
                        pending = trading
                    case .exchange:
                        fatalError("Exchange account types are not supported.")
                    }
                case .nonCustodial:
                    pending = wallet
                }

                switch state {
                case .calculating, .invalid:
                    return .loading
                case .value(let result):
                    return .loaded(
                        next: .init(
                            fiatValue: result[self.accountType].quote,
                            cryptoValue: result[self.accountType].base,
                            pendingValue: pending
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

    public init(assetBalanceFetching: AssetBalanceFetching, accountType: SingleAccountType) {
        self.accountType = accountType
        self.assetBalanceFetching = assetBalanceFetching
    }
}
