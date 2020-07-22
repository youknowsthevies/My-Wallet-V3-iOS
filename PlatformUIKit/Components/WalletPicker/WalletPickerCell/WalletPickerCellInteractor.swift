//
//  WalletPickerCellInteractor.swift
//  Blockchain
//
//  Created by Alex McGregor on 5/5/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit

public enum WalletPickerCellInteractor {
    case total(WalletBalanceCellInteracting)
    case balance(CurrentBalanceCellInteracting, CryptoCurrency)
}
