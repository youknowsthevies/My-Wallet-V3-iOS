// Copyright © Blockchain Luxembourg S.A. All rights reserved.

struct EligibilityResponse: Decodable {
    let eligible: Bool
    let simpleBuyTradingEligible: Bool
    let simpleBuyPendingTradesEligible: Bool
    let pendingDepositSimpleBuyTrades: Int
    let pendingConfirmationSimpleBuyTrades: Int
    let maxPendingDepositSimpleBuyTrades: Int
    let maxPendingConfirmationSimpleBuyTrades: Int
}
