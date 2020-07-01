//
//  AppReviewPrompt.swift
//  Blockchain
//
//  Created by Maurice A. on 6/29/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import PlatformKit
import StoreKit
import ToolKit

/**
 App Review Prompt
 Used to prompt the user to review the application.
 */
@objc
final class AppReviewPrompt: NSObject {

    // MARK: - Properties

    private let numberOfTransactionsBeforePrompt = 3

    static let shared = AppReviewPrompt()

    @objc class func sharedInstance() -> AppReviewPrompt {
        AppReviewPrompt.shared
    }

    override private init() {
        super.init()
    }

    /// Ask to show the prompt, else handle failure silently
    @objc func showIfNeeded() {
        let transactionsCount = WalletManager.shared.wallet.getAllTransactionsCount()
        if transactionsCount < numberOfTransactionsBeforePrompt {
            Logger.shared.info("App review prompt will not show because the user needs at least \(numberOfTransactionsBeforePrompt) transactions.")
            return
        }
        // TODO: support overriding appBecameActiveCount for debugging
        let count = BlockchainSettings.App.shared.appBecameActiveCount
        switch count {
        case 10, 50,
             _ where (count >= 100) && (count % 100 == 0),
             _ where transactionsCount == numberOfTransactionsBeforePrompt: requestReview()
        default:
            Logger.shared.info("App review prompt will not show because the application open count is too low (\(count)).")
            return
        }
    }

    private func requestReview() {
        SKStoreReviewController.requestReview()
    }
}
