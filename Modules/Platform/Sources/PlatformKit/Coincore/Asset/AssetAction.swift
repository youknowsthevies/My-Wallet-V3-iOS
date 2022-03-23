// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public enum AssetAction: Equatable, CaseIterable {
    case buy
    case deposit
    case interestTransfer
    case interestWithdraw
    case receive
    case sell
    case send
    case sign
    case swap
    case viewActivity
    case withdraw
}

extension AssetAction: CustomStringConvertible, CustomDebugStringConvertible {

    public var description: String {
        switch self {
        case .buy:
            return "buy"
        case .deposit:
            return "deposit"
        case .interestTransfer:
            return "interestTransfer"
        case .interestWithdraw:
            return "interestWithdraw"
        case .receive:
            return "receive"
        case .sell:
            return "sell"
        case .send:
            return "send"
        case .sign:
            return "sign"
        case .swap:
            return "swap"
        case .viewActivity:
            return "viewActivity"
        case .withdraw:
            return "withdraw"
        }
    }

    public var debugDescription: String {
        description
    }
}
