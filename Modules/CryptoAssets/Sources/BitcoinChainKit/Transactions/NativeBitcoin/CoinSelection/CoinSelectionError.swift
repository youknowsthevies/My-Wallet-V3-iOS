// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public enum CoinSelectionError: Error {
    case noCoinsToSelect
    case noEffectiveCoins
    case noSelectedCoins
    case insufficientFunds
}
