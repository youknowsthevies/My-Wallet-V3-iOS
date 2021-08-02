// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

/// Supported products list for an `AssetModel`.
public enum AssetModelProduct: String, Hashable, CaseIterable {
    case privateKey = "PrivateKey"
    case mercuryDeposits = "MercuryDeposits"
    case mercuryWithdrawals = "MercuryWithdrawals"
    case interestBalance = "InterestBalance"
    case custodialWalletBalance = "CustodialWalletBalance"
}
