// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformKit
import RxRelay
import RxSwift

public final class AccountAssetBalanceViewInteractor: AssetBalanceViewInteracting {

    public typealias InteractionState = AssetBalanceViewModel.State.Interaction

    // MARK: - Exposed Properties

    public var state: Observable<InteractionState> {
        _ = setup
        return stateRelay.asObservable()
    }

    private let stateRelay = BehaviorRelay<InteractionState>(value: .loading)
    private let disposeBag = DisposeBag()
    private let fiatCurrencyService: FiatCurrencyServiceAPI

    let account: SingleAccount

    // MARK: - Setup

    private lazy var setup: Void = {
        fiatCurrencyService.fiatCurrencyObservable
            .flatMap(weak: self) { (self, fiatCurrency) -> Observable<MoneyValuePair> in
                self.account.balancePair(fiatCurrency: fiatCurrency)
            }
            .map { moneyValuePair -> InteractionState in
                InteractionState.loaded(
                    next: AssetBalanceViewModel.Value.Interaction.init(
                        fiatValue: moneyValuePair.quote,
                        cryptoValue: moneyValuePair.base,
                        pendingValue: .zero(currency: moneyValuePair.base.currency)
                    )
                )
            }
            .subscribe(onNext: { [weak self] state in
                self?.stateRelay.accept(state)
            })
            .disposed(by: disposeBag)
    }()

    public init(account: SingleAccount,
                fiatCurrencyService: FiatCurrencyServiceAPI = resolve()) {
        self.account = account
        self.fiatCurrencyService = fiatCurrencyService
    }
}
