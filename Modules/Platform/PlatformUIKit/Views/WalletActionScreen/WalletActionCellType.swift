// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxDataSources

public enum WalletActionCellType: IdentifiableType, Equatable {

    public typealias Identity = String

    /// A cell that shows the wallets balance
    case balance(CurrentBalanceCellPresenter)
    case `default`(DefaultWalletActionCellPresenter)

    public var identity: String {
        switch self {
        case .balance(let presenter):
            return presenter.currency.code
        case .default(let presenter):
            return presenter.action.identity
        }
    }
}

public extension WalletActionCellType {
    static func ==(lhs: WalletActionCellType, rhs: WalletActionCellType) -> Bool {
        switch (lhs, rhs) {
        case (.balance(let left), .balance(let right)):
            return left.currency.code == right.currency.code
        case (.default(let left), .default(let right)):
            return left.action == right.action
        default:
            return false
        }
    }
}
