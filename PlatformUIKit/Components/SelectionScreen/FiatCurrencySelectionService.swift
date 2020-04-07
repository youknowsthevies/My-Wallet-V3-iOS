//
//  FiatCurrencySelectionService.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 20/02/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay
import PlatformKit

extension Notification.Name {
    public static let fiatCurrencySelected = Notification.Name("fiat_currency_selected")
}

public final class FiatCurrencySelectionService: SelectionServiceAPI {
    
    public var dataSource: Observable<[SelectionItemViewModel]> {
        .just(availableCurrencies.map { $0.selectionItem })
    }
    
    public let selectedDataRelay: BehaviorRelay<SelectionItemViewModel>
    
    public var selectedData: Observable<SelectionItemViewModel> {
        selectedDataRelay.distinctUntilChanged()
    }
    
    private let availableCurrencies: [FiatCurrency]
    
    public init(defaultSelectedData: FiatCurrency = .locale,
                availableCurrencies: [FiatCurrency] = FiatCurrency.supported) {
        self.availableCurrencies = availableCurrencies
        self.selectedDataRelay = BehaviorRelay(value: defaultSelectedData.selectionItem)
    }
}

private extension FiatCurrency {
    var selectionItem: SelectionItemViewModel {
        SelectionItemViewModel(
            id: code,
            title: name,
            subtitle: code,
            thumb: .none
        )
    }
}
