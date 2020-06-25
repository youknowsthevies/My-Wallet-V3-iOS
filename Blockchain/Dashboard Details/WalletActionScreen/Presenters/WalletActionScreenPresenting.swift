//
//  WalletActionScreenPresenting.swift
//  Blockchain
//
//  Created by AlexM on 2/27/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import PlatformUIKit
import RxCocoa
import RxSwift

enum WalletActionCellType {
    /// A cell that shows the wallets balance
    case balance
}

protocol WalletActionScreenPresenting: class {
    
    /// Returns the total count of cells
    var cellCount: Int { get }
    
    /// Returns the ordered cell types
    var cellArrangement: [WalletActionCellType] { get }
    
    /// Visibility of the `Swap` button
    var swapButtonVisibility: Driver<Visibility> { get }
    
    /// Visibility of the `Activity` button
    var activityButtonVisibility: Driver<Visibility> { get }
    
    /// Visibility of the `Send to Wallet` button
    var sendToWalletVisibility: Driver<Visibility> { get }
    
    /// Presenter for `balance` cell
    var assetBalanceViewPresenter: CurrentBalanceCellPresenter { get }
    
    /// `ViewModels` for buttons
    var sendToWalletViewModel: ButtonViewModel { get }
    var activityButtonViewModel: ButtonViewModel { get }
    var swapButtonViewModel: ButtonViewModel { get }
    
    /// The selected `CryptoCurrency`
    var currency: CryptoCurrency { get }
}
