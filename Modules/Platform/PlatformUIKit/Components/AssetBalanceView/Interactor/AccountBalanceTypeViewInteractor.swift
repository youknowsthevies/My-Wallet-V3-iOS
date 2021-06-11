// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformKit
import RxSwift
import ToolKit

public final class AccountBalanceTypeViewInteractor: AssetBalanceTypeViewInteracting {

    public typealias InteractionState = AssetBalanceViewModel.State.Interaction
    private typealias Model = AssetBalanceViewModel.Value.Interaction

    // MARK: - Exposed Properties

    public lazy var accountType: SingleAccountType = {
        switch account {
        case is CryptoInterestAccount:
            return .custodial(.savings)
        case is TradingAccount,
             is FiatAccount:
            return .custodial(.trading)
        case is ExchangeAccount:
            return .custodial(.exchange)
        case is CryptoNonCustodialAccount:
            return .nonCustodial
        default:
            unimplemented("Unsupported account type: \(String(reflecting: account))")
        }
    }()

    public var state: Observable<InteractionState> {
        let balancePair = fiatCurrencyService
            .fiatCurrencyObservable
            .flatMapLatest(weak: self) { (self, fiatCurrency) in
                self.account.balancePair(fiatCurrency: fiatCurrency)
            }
        let pendingBalance = account.pendingBalance.asObservable()
        return Observable.combineLatest(balancePair, pendingBalance) { (balancePair: $0, pendingBalance: $1) }
            .map { data -> InteractionState in
                let value = AssetBalanceViewModel.Value.Interaction(
                    fiatValue: data.balancePair.quote,
                    cryptoValue: data.balancePair.base,
                    pendingValue: data.pendingBalance
                )
                return .loaded(next: value)
            }
    }

    // MARK: - Private Accessors

    private let account: BlockchainAccount
    private let fiatCurrencyService: FiatCurrencyServiceAPI

    // MARK: - Setup

    public init(
        account: BlockchainAccount,
        fiatCurrencyService: FiatCurrencyServiceAPI = resolve()
    ) {
        self.account = account
        self.fiatCurrencyService = fiatCurrencyService
    }
}
