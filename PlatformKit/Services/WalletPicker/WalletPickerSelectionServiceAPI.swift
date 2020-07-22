//
//  WalletPickerSelectionServiceAPI.swift
//  PlatformKit
//
//  Created by Paulo on 21/07/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxCocoa
import RxSwift

public protocol WalletPickerSelectionServiceAPI: class {
    var selectedDataRelay: BehaviorRelay<WalletPickerSelection> { get }
    var selectedData: Observable<WalletPickerSelection> { get }
}

public final class WalletPickerSelectionService: WalletPickerSelectionServiceAPI {
    public let selectedDataRelay: BehaviorRelay<WalletPickerSelection>

    public var selectedData: Observable<WalletPickerSelection> {
        selectedDataRelay.distinctUntilChanged()
    }

    public init(defaultSelection: WalletPickerSelection) {
        self.selectedDataRelay = BehaviorRelay(value: defaultSelection)
    }
}
