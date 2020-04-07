//
//  SimpleBuyCryptoCurrencySelectionService.swift
//  Blockchain
//
//  Created by Daniel Huri on 31/01/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay
import ToolKit
import PlatformKit
import PlatformUIKit

final class SimpleBuyCryptoCurrencySelectionService: SelectionServiceAPI {
    
    var dataSource: Observable<[SelectionItemViewModel]> {
        service.valueObservable
            .map { $0.cryptoCurrencies }
            .take(1)
            .map { $0.map(\.selectionItem) }
    }
    
    let selectedDataRelay: BehaviorRelay<SelectionItemViewModel>
    
    var selectedData: Observable<SelectionItemViewModel> {
        selectedDataRelay.distinctUntilChanged()
    }
    
    private let service: SimpleBuySupportedPairsInteractorServiceAPI
    
    init(service: SimpleBuySupportedPairsInteractorServiceAPI, defaultSelectedData: CryptoCurrency) {
        self.service = service
        self.selectedDataRelay = BehaviorRelay(value: defaultSelectedData.selectionItem)
    }
}

fileprivate extension CryptoCurrency {
    var selectionItem: SelectionItemViewModel {
        SelectionItemViewModel(
            id: code,
            title: name,
            subtitle: displayCode,
            thumb: .name(logoImageName)
        )
    }
}
