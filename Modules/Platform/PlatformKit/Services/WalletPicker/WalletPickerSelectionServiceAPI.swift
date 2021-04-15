//
//  WalletPickerSelectionServiceAPI.swift
//  PlatformKit
//
//  Created by Paulo on 21/07/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxRelay
import RxSwift

public protocol WalletPickerSelectionServiceAPI: class {
    var selectedData: Observable<WalletPickerSelection> { get }
    func record(selection: WalletPickerSelection)
}

public final class WalletPickerSelectionService: WalletPickerSelectionServiceAPI {
    private let selectedDataRelay: BehaviorRelay<WalletPickerSelection>

    public var selectedData: Observable<WalletPickerSelection> {
        selectedDataRelay.distinctUntilChanged()
    }

    public init(defaultSelection: WalletPickerSelection) {
        self.selectedDataRelay = BehaviorRelay(value: defaultSelection)
    }

    public func record(selection: WalletPickerSelection) {
        selectedDataRelay.accept(selection)
    }
}
