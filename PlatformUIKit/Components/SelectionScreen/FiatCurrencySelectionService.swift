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

public final class FiatCurrencySelectionService: SelectionServiceAPI {
    
    public var dataSource: Observable<[SelectionItemViewModel]> {
        .just(availableCurrencies.map { $0.selectionItem })
    }
    
    public let selectedDataRelay: BehaviorRelay<SelectionItemViewModel>
    
    public var selectedData: Observable<SelectionItemViewModel> {
        selectedDataRelay.distinctUntilChanged()
    }
    
    private let availableCurrencies = FiatCurrency.supported
    
    public init(defaultSelectedData: FiatCurrency = .locale) {
        self.selectedDataRelay = BehaviorRelay(value: defaultSelectedData.selectionItem)
    }
}

fileprivate extension FiatCurrency {
    
    var selectionItem: SelectionItemViewModel {
        SelectionItemViewModel(
            id: code,
            name: name,
            thumbImage: .none
        )
    }
}
