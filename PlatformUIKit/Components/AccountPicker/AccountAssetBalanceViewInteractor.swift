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

final class AccountAssetBalanceViewInteractor: AssetBalanceViewInteracting {

    typealias InteractionState = DashboardAsset.State.AssetBalance.Interaction

    // MARK: - Exposed Properties

    var state: Observable<InteractionState> {
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
                ) { (fiatBalance: $0, cryptoBalance: $1) }
            }
            .map { data -> InteractionState in
                InteractionState.loaded(
                    next: DashboardAsset.Value.Interaction.AssetBalance(
                        fiatValue: data.fiatBalance,
                        cryptoValue: data.cryptoBalance
                    )
                )
            }
            .subscribe(onSuccess: { [weak self] state in
                self?.stateRelay.accept(state)
            })
            .disposed(by: disposeBag)
    }()

    init(account: SingleAccount,
         fiatCurrencyService: FiatCurrencyServiceAPI = resolve()) {
        self.account = account
        self.fiatCurrencyService = fiatCurrencyService
    }
}
