//
//  WalletPickerSelectionService.swift
//  Blockchain
//
//  Created by Alex McGregor on 5/7/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxRelay
import RxSwift

final class WalletPickerSelectionService: WalletPickerSelectionServiceAPI {
    let selectedDataRelay: BehaviorRelay<WalletPickerSelection>
    
    var selectedData: Observable<WalletPickerSelection> {
        selectedDataRelay.distinctUntilChanged()
    }
    
    init(defaultSelection: WalletPickerSelection) {
        self.selectedDataRelay = BehaviorRelay(value: defaultSelection)
    }
}
