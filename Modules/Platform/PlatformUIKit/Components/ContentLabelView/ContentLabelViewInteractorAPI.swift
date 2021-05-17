// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import RxCocoa
import RxSwift
import ToolKit

public protocol ContentLabelViewInteractorAPI {
    var contentCalculationState: Observable<ValueCalculationState<String>> { get }
}

@available(*, deprecated, message: "Use `AvailableBalanceContentInteractor` instead which uses the Coincore API")
public final class AvailableBalanceContentViewInteractor: ContentLabelViewInteractorAPI {

    public var contentCalculationState: Observable<ValueCalculationState<String>> {
        balanceProvider[currencyType].calculationState
            .distinctUntilChanged()
            .mapCalculationState { balance -> String in
                balance[.custodial(.trading)].quote.toDisplayString(includeSymbol: true)
            }
    }

    private let balanceProvider: BalanceProviding
    private let currencyType: CurrencyType

    public init(balanceProvider: BalanceProviding,
                currencyType: CurrencyType) {
        self.balanceProvider = balanceProvider
        self.currencyType = currencyType
    }
}
