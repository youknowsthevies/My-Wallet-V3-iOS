//
//  CountrySelectionService.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 31/03/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxRelay
import RxSwift

public final class CountrySelectionService: SelectionServiceAPI {
    
    public var dataSource: Observable<[SelectionItemViewModel]> {
        .just(Country.all.map { $0.selectionItem }.sorted() )
    }
    
    public let selectedDataRelay: BehaviorRelay<SelectionItemViewModel>
    
    public var selectedData: Observable<SelectionItemViewModel> {
        selectedDataRelay.distinctUntilChanged()
    }
    
    public init(defaultSelectedData: Country) {
        self.selectedDataRelay = BehaviorRelay(value: defaultSelectedData.selectionItem)
    }
    
    public func set(country: Country) {
        selectedDataRelay.accept(country.selectionItem)
    }
}

private extension Country {
    var selectionItem: SelectionItemViewModel {
        SelectionItemViewModel(
            id: code,
            title: name,
            subtitle: code,
            thumb: .emoji(flag)
        )
    }
}

