//
//  AccountAssetBalanceViewInteractor.swift
//  PlatformUIKit
//
//  Created by Paulo on 06/08/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

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
        fiatCurrencyService.fiatCurrency
            .flatMap(weak: self) { (self, fiatCurrency) in
                Single.zip(
                    self.account.fiatBalance(fiatCurrency: fiatCurrency),
                    self.account.balance
                )
            }
            .map { (fiatBalance: $0, cryptoBalance: $1) }
            .map { data -> InteractionState in
                InteractionState.loaded(
                    next: AssetBalanceViewModel.Value.Interaction.init(
                        fiatValue: data.fiatBalance,
                        cryptoValue: data.cryptoBalance,
                        pendingValue: .zero(currency: data.cryptoBalance.currency)
                    )
                )
            }
            .subscribe(onSuccess: { [weak self] state in
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
