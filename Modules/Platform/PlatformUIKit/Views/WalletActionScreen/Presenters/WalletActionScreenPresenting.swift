// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization
import PlatformKit
import RxCocoa
import RxSwift

public protocol WalletActionScreenPresenting: AnyObject {

    var selectionRelay: PublishRelay<WalletActionCellType> { get }

    var sections: Observable<[WalletActionItemsSectionViewModel]> { get }

    /// Presenter for `balance` cell
    var assetBalanceViewPresenter: CurrentBalanceCellPresenter { get }

    /// The selected `CryptoCurrency`
    var currency: CurrencyType { get }
}
