//
//  CryptoCurrencySelectionService.swift
//  Blockchain
//
//  Created by Daniel Huri on 31/01/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import BuySellKit
import PlatformKit
import PlatformUIKit
import RxRelay
import RxSwift
import ToolKit

public protocol CryptoCurrencySelectionServiceAPI: SelectionServiceAPI, CryptoCurrencyServiceAPI {}

final class CryptoCurrencySelectionService: CryptoCurrencySelectionServiceAPI {
    
    var dataSource: Observable<[SelectionItemViewModel]> {
        service.pairs
            .map { $0.cryptoCurrencies }
            .take(1)
            .map { $0.map(\.selectionItem) }
    }
    
    let selectedDataRelay: BehaviorRelay<SelectionItemViewModel>
    
    var selectedData: Observable<SelectionItemViewModel> {
        selectedDataRelay.distinctUntilChanged()
    }
    
    var cryptoCurrencyObservable: Observable<CryptoCurrency> {
        cryptoCurrencyRelay
            .asObservable()
            .distinctUntilChanged()
    }
    
    var cryptoCurrency: Single<CryptoCurrency> {
        cryptoCurrencyObservable
            .take(1)
            .asSingle()
    }
        
    // MARK: - Injected
    
    private let service: SupportedPairsInteractorServiceAPI
    
    // MARK: - Accessors
    
    private let cryptoCurrencyRelay: BehaviorRelay<CryptoCurrency>
    private let disposeBag = DisposeBag()
            
    init(service: SupportedPairsInteractorServiceAPI,
         defaultSelectedData: CryptoCurrency) {
        self.service = service
        selectedDataRelay = BehaviorRelay(value: defaultSelectedData.selectionItem)
        cryptoCurrencyRelay = BehaviorRelay(value: defaultSelectedData)
        
        selectedData
            .map {  CryptoCurrency(code: $0.id)! }
            .bindAndCatch(to: cryptoCurrencyRelay)
            .disposed(by: disposeBag)
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
