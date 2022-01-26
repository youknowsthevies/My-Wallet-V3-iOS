// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

enum CoinSelectionError: Error {
    case noCoinsToSelect
    case noEffectiveCoins
    case noSelectedCoins
    case insufficientFunds
}
