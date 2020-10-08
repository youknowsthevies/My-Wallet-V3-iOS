//
//  ContentLabelViewInteractorAPI.swift
//  PlatformUIKit
//
//  Created by Daniel on 06/08/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RIBs
import RxCocoa
import RxSwift
import ToolKit

public protocol ContentLabelViewInteractorAPI: Interactable {
    var contentCalculationState: Observable<ValueCalculationState<String>> { get }
}

public final class AvailableBalanceContentViewInteractor: Interactor, ContentLabelViewInteractorAPI {
    
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
