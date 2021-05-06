// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ToolKit

extension UserDefaults {

    // TICKET: IOS-1289 - Refactor key-value mapping such that key = value
    // Refactor simulateZeroTicker, shouldHideBuySellCard,
    // swipeToReceiveEnabled such that key = value (where possible)
    enum DebugKeys: String {
        case appReviewPromptCount = "debug_appReviewPromptCount"
        case securityReminderTimer = "debug_securiterReminderTimer"
        case simulateSurge = "debug_simulateSurge"
        case simulateZeroTicker = "debug_zeroTicker"
        case createWalletPrefill = "debug_createWalletPrefill"
        case createWalletEmailPrefill = "debug_createWalletEmailPrefill"
        case createWalletEmailRandomSuffix = "debug_createWalletEmailRandomSuffix"
        case useHomebrewForExchange = "debug_useHomebrewForExchange"
        case mockExchangeOrderDepositAddress = "debug_mockExchangeOrderDepositAddress"
        case mockExchangeDeposit = "debug_mockExchangeDeposit"
        case mockExchangeDepositQuantity = "debug_mockExchangeDepositQuantity"
        case mockExchangeDepositAssetTypeString = "debug_mockExchangeDepositAssetTypeString"
    }

    enum Keys: String {
        case graphTimeFrameKey = "timeFrame"
        case hasSeenAirdropJoinWaitlistCard
        case hasSeenGetFreeXlmModal
        case didRegisterForAirdropCampaignSucceed
        case walletIntroLatestLocation
        case firstRun
    }
}
