//
//  StoreReviewController.swift
//  PlatformUIKit
//
//  Created by Paulo on 27/01/2021.
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

import StoreKit
import ToolKit

public final class StoreReviewController {

    public class func requestReview() {
        let disableRating = ProcessInfo.processInfo
            .environmentBoolean(for: .disableRatingPrompt) ?? false
        guard !disableRating else {
            Logger.shared.debug("Store Review disable due to automation_disable_rating_prompt.")
            return
        }
        SKStoreReviewController.requestReview()
    }
}
